class Order < ApplicationRecord
  include SearchCop
  acts_as_tenant :account
  has_prefix_id :order

  search_scope :search do
    attributes :id, :total_amount_cents, :number
    # Use exact match for encrypted fields as deterministic encryption does not support LIKE
    attributes customer: "customer.name"
  end

  belongs_to :customer
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :staff_notes, as: :notable, class_name: "Note", dependent: :destroy

  accepts_nested_attributes_for :order_items, allow_destroy: true

  monetize :total_amount_cents

  enum :status, { ordered: 0, awaiting_collection: 1, complete: 2 }

  validates :status, presence: true
  validates :number, presence: true, uniqueness: true

  before_validation :generate_number, on: :create
  before_validation :calculate_total
  after_create :send_received_email
  after_update :send_status_emails, if: :saved_change_to_status?

  private

  def generate_number
    return if number.present?

    self.number = loop do
      random_number = Array.new(3) { rand(1..9) }.join + Array.new(3) { ("A".."Z").to_a.sample }.join
      break random_number unless Order.exists?(number: random_number)
    end
  end

  def calculate_total
    order_items.each { |item| item.set_default_price if item.new_record? }
    self.total_amount_cents = order_items.reject(&:marked_for_destruction?).sum { |item| item.price_cents * item.quantity }
  end

  def send_received_email
    OrderMailer.order_received(self).deliver_later
  end

  def send_status_emails
    if awaiting_collection?
      OrderMailer.order_awaiting_collection(self).deliver_later
    end
  end
end
