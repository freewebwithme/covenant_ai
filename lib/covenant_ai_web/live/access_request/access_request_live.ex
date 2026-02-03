defmodule CovenantAIWeb.AccessRequest.AccessRequestLive do
  @moduledoc """
  LiveView for public access request form.

  Allows potential Board Admins to submit requests to join
  Covenant AI platform.
  """
  use CovenantAIWeb, :live_view

  alias CovenantAI.Accounts.AccessRequest

  @impl true
  def mount(_params, _session, socket) do
    form =
      AccessRequest
      |> AshPhoenix.Form.for_create(:create,
        forms: [
          hoa_address: [
            type: :single,
            resource: CovenantAI.Communities.Address,
            create_action: :create,
            update_action: :update
          ]
        ],
        as: "access_request"
      )
      |> AshPhoenix.Form.add_form(:hoa_address)
      |> to_form()

    {:ok,
     socket
     |> assign(:page_title, "Request Access")
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("validate", %{"access_request" => params}, socket) do
    {:noreply, assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, params))}
  end

  @impl true
  def handle_event("submit", %{"access_request" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, _access_request} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Access request submitted successfully! We'll review your application and get back to you soon."
         )
         |> push_navigate(to: ~p"/")}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-base-200 py-12 px-4">
      <div class="max-w-3xl mx-auto">
        <div class="card bg-base-100 shadow-xl">
          <div class="card-body">
            <h1 class="card-title text-3xl mb-2">
              Request Access to Covenant AI
            </h1>
            <p class="text-base-content/70 mb-6">
              Join our platform to streamline your HOA management with
              AI-powered tools.
            </p>

            <.form
              for={@form}
              phx-change="validate"
              phx-submit="submit"
              class="space-y-6"
            >
              <%!-- Personal Information --%>
              <div class="divider">Personal Information</div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text font-semibold">
                    Full Name <span class="text-error">*</span>
                  </span>
                </label>
                <.input
                  type="text"
                  field={@form[:full_name]}
                  class="input input-bordered w-full"
                  placeholder="John Doe"
                  required
                />
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold">
                      Email <span class="text-error">*</span>
                    </span>
                  </label>
                  <.input
                    type="email"
                    field={@form[:email]}
                    class="input input-bordered w-full"
                    placeholder="john@example.com"
                    required
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold">
                      Phone <span class="text-error">*</span>
                    </span>
                  </label>
                  <.input
                    type="tel"
                    field={@form[:phone]}
                    class="input input-bordered w-full"
                    placeholder="(555) 123-4567"
                    required
                  />
                </div>
              </div>

              <%!-- HOA Information --%>
              <div class="divider">HOA Information</div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text font-semibold">
                    HOA Name <span class="text-error">*</span>
                  </span>
                </label>
                <.input
                  type="text"
                  field={@form[:hoa_name]}
                  class="input input-bordered w-full"
                  placeholder="Sunset Hills HOA"
                  required
                />
              </div>

              <%!-- HOA Address (Embedded) --%>
              <.inputs_for :let={address_form} field={@form[:hoa_address]}>
                <div class="border border-base-300 rounded-lg p-4 space-y-4">
                  <h3 class="font-semibold text-sm">
                    HOA Address <span class="text-error">*</span>
                  </h3>

                  <div class="form-control">
                    <label class="label">
                      <span class="label-text">Street Address</span>
                    </label>
                    <.input
                      type="text"
                      field={address_form[:street_address]}
                      class="input input-bordered w-full"
                      placeholder="123 Main Street"
                      required
                    />
                  </div>

                  <div class="form-control">
                    <label class="label">
                      <span class="label-text">
                        Street Address 2 (Optional)
                      </span>
                    </label>
                    <.input
                      type="text"
                      field={address_form[:street_address_2]}
                      class="input input-bordered w-full"
                      placeholder="Suite 100"
                    />
                  </div>

                  <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div class="form-control col-span-2">
                      <label class="label">
                        <span class="label-text">City</span>
                      </label>
                      <.input
                        type="text"
                        field={address_form[:city]}
                        class="input input-bordered w-full"
                        placeholder="Los Angeles"
                        required
                      />
                    </div>

                    <div class="form-control">
                      <label class="label">
                        <span class="label-text">State</span>
                      </label>
                      <.input
                        type="text"
                        field={address_form[:state]}
                        class="input input-bordered w-full"
                        placeholder="CA"
                        maxlength="2"
                        required
                      />
                    </div>

                    <div class="form-control">
                      <label class="label">
                        <span class="label-text">ZIP Code</span>
                      </label>
                      <.input
                        type="text"
                        field={address_form[:zip_code]}
                        class="input input-bordered w-full"
                        placeholder="90210"
                        required
                      />
                    </div>
                  </div>
                </div>
              </.inputs_for>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold">
                      Your Role in HOA <span class="text-error">*</span>
                    </span>
                  </label>
                  <.input
                    type="text"
                    field={@form[:role_in_hoa]}
                    class="input input-bordered w-full"
                    placeholder="Board President, Treasurer, etc."
                    required
                  />
                </div>

                <div class="form-control">
                  <label class="label">
                    <span class="label-text font-semibold">
                      Estimated Number of Units
                    </span>
                  </label>
                  <.input
                    type="number"
                    field={@form[:estimated_units]}
                    class="input input-bordered w-full"
                    placeholder="100"
                    min="1"
                  />
                </div>
              </div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text font-semibold">
                    HOA Website (Optional)
                  </span>
                </label>
                <.input
                  type="url"
                  field={@form[:website]}
                  class="input input-bordered w-full"
                  placeholder="https://example-hoa.com"
                />
              </div>

              <%!-- Additional Information --%>
              <div class="divider">Additional Information</div>

              <div class="form-control">
                <label class="label">
                  <span class="label-text font-semibold">
                    How did you hear about us?
                  </span>
                </label>
                <.input
                  type="text"
                  field={@form[:how_found_us]}
                  class="input input-bordered w-full"
                  placeholder="Google search, referral, social media, etc."
                />
              </div>

              <%!-- Submit Button --%>
              <div class="card-actions justify-end mt-8">
                <button type="submit" class="btn btn-primary btn-lg" phx-disable-with="Submitting...">
                  Submit Request
                </button>
              </div>
            </.form>
          </div>
        </div>

        <%!-- Info Card --%>
        <div class="alert alert-info mt-6">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            class="stroke-current shrink-0 w-6 h-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            >
            </path>
          </svg>
          <div>
            <h3 class="font-bold">What happens next?</h3>
            <div class="text-sm">
              Our team will review your application and get back to you
              within 2-3 business days. If approved, you'll receive an
              invitation email to create your account.
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
