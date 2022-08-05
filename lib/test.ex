defmodule Test do
  def test_parse() do
    File.read!("/test/aa.html")
    |> IO.inspect(label: "html_body")
    |> Floki.parse_document!()
    |> Floki.find("#download-wrapper")
    |> Floki.find("a")
    |> Floki.attribute("href")
  end
end
