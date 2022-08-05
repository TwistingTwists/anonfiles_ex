defmodule HTTP.API do
  def handle_result_json({:ok, response}) do
    response.body
    |> IO.inspect(label: "response.body")
    |> Jason.decode!()
  end

  def handle_result_json(error) do
    {:error, "#{inspect(error)}"}
  end

  def handle_html({:ok, response}) do
    {:ok, html_body} =
      response.body
      |> Floki.parse_document()

    cdn_url =
      html_body
      |> Floki.find("#download-wrapper")
      |> Floki.find("a")
      |> Floki.attribute("href")

    # returns url
    {:ok, cdn_url}
  end

  def handle_html(error) do
    {:error, "#{inspect(error)}"}
  end
end
