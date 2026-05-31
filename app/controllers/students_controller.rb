class StudentsController < ApplicationController
  before_action :set_student, only: %i[ show edit update destroy ]
  after_action :verify_authorized, except: :index

  # GET /students or /students.json
  def index
    @students = Student.all
  end

  # GET /students/1 or /students/1.json
  def show
    authorize @student
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
    authorize @student
  end

  # POST /students or /students.json
  def create
    @student = Student.new(student_params)

    authorize @student

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: "Student was successfully created." }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @student.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /students/1 or /students/1.json
  def update
    authorize @student

    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: "Student was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @student.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /students/1 or /students/1.json
  def destroy
    @student.destroy!

    respond_to do |format|
      format.html { redirect_to students_path, notice: "Student was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def student_params
      params.expect(student: [ :student_urn, :name, :date_of_birth, :address, :phone ])
    end
end
