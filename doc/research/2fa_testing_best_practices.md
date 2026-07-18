### 2FA/TOTP Testing Best Practices in Ruby on Rails

Researching high-quality implementations (Basecamp, 37signals, Rails 8) reveals several first principles for building robust, non-flaky 2FA tests.

#### 1. Deterministic Time (Critical Factor)
TOTP (Time-based One-Time Password) relies on 30-second windows. Flakiness within Continuous Integration (CI) is often caused by the test generating a code at the end of a window (e.g., second 29) and the server receiving it at the start of the next (e.g., second 31).

- **Best Practice:** Use `travel_to` from `ActiveSupport::Testing::TimeHelpers` to freeze time during the code generation and submission.
- **Wait Times:** Be aware that `travel_to` freezes the system clock. While Capybara usually uses monotonic time for its own timeouts, some internal Rails/Test logic might rely on `Time.current`. If a test hangs or fails to find an element, ensure that any necessary asynchronous processes (like background mailers or DB updates) have completed *before* entering the frozen time block.
- **Example:**
  ```ruby
  # Wait for asynchronous state (e.g., DB token generation) BEFORE freezing time
  token = wait_for_token(@user) 

  travel_to Time.current do
    fill_in "otp_code", with: token
    click_button "Verify"
  end
  ```

#### 2. Realistic Integration (Avoid Mocks)
Following the Basecamp philosophy, avoid mocking the TOTP verification logic itself. Mocks can hide bugs where the secret is stored incorrectly (e.g., missing padding or leading/trailing whitespace).

- **Best Practice:** Use the real `ROTP` library in tests to generate codes from the user's actual `otp_secret`.
- **Verification:** Ensure `otp_secret` is correctly stripped of whitespace, as `ROTP` is sensitive to it.
- **Alphanumeric Tokens:** For email-based OTP, verify that the test handles mixed-case or alphanumeric tokens correctly, mirroring the real user experience.

#### 3. System Test Synchronization
System tests fail when they interact with elements before the page is fully interactive.

- **Best Practices:**
  - **Wait for Elements:** Use `assert_selector` or `assert_field` with explicit `wait` times to ensure the page has transitioned.
  - **Actionable Elements:** Prefer `fill_in` and `click_button` over generic `find().set()` or `find().click` to benefit from Capybara's built-in waiting and visibility checks.
  - **Robust Input Verification:** In high-latency environments, `fill_in` can occasionally fail to synchronize with the browser. Adding an explicit `assert_field` check before submission, with a fallback to `find_field().set()`, ensures the field is correctly populated before the form is sent.
  - **Flash Messages:** Asserting the presence of a success flash message (e.g., "Signed in successfully") is often more reliable than strictly checking the final URL, as it confirms the logical completion of the action.

#### 4. Clean State & Flow Control
2FA is often part of a multi-step onboarding or security setup flow. Tests should explicitly control these flags to avoid "interruption redirects."

- **Best Practice:** In the `setup` block, explicitly set flags like `onboarded: true` and `security_choice_made: true` unless the test specifically targets those flows.

#### 5. Turbo-Aware Redirections
Modern Rails apps using Turbo expect `303 See Other` for redirects after POST requests.

- **Best Practice:** Ensure all authentication controllers use `status: :see_other` for redirects to prevent Turbo from misinterpreting the response.

#### 6. Failure Isolation
Large, monolithic "happy path" tests are hard to debug when they fail in CI.

- **Best Practice:** Split the authentication flow into discrete units:
  1. Phase 1: Valid credentials -> Redirected to 2FA prompt.
  2. Phase 2: Valid OTP -> Successful login.
  3. Phase 2: Invalid OTP -> Error message.
