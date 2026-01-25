defmodule CovenantAiWeb.PageController do
  use CovenantAiWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
