defmodule AnonDown do
  @moduledoc """
  Documentation for `AnonDown`.
  """
  @base_url "https://api.filechan.org"

  import HTTPoison.Retry
  import HTTP.API

  def download(url, retries_count \\ 5) do
    %{
      "data" => %{
        "file" => %{
          "metadata" => %{
            "id" => file_id,
            "name" => file_name,
            "size" => %{"bytes" => file_size, "readable" => readable_size}
          },
          "url" => %{
            "full" => full_url,
            "short" => short_url
          }
        }
      },
      "status" => status
    } = info(url)

    IO.inspect("#{retries_count} -> trying url -> #{full_url}")

    {:ok, cdn_url} = download_page(full_url) |> IO.inspect(label: "download_page")

    if(status) do
      file = File.open!(file_name |> with_extension(), [:write])

      http_poison_opts = [headers: [{"Accept", "application/json"}, {"User-Agent", "AnonDown"}]]

      case Downstream.get(cdn_url, file, http_poison_opts) do
        {:ok, file} ->
          {:ok, file}

        {:error, err} ->
          :timer.sleep(1500)

          if retries_count > 0 do
            IO.inspect("got - #{inspect(err)} \n")
            download(url, retries_count - 1)
          else
            {:error, "#{inspect(err)} - could not download after 5 retires"}
          end
      end

      File.close(file)
      IO.inspect("#{file_name} downloaded", label: "AnonDown - Download Task completed")
      file_name |> with_extension()
    else
      {:error, "Could not download file becuase #{status}"}
    end
  end

  @doc """
  %{
  "data" => %{
    "file" => %{
      "metadata" => %{
        "id" => "O80cxd2ayd",
        "name" => "039_08-06-22_B2_Opt_Sociology_5pm_to_8pm_mp4",
        "size" => %{"bytes" => 461797711, "readable" => "440.4 MB"}
      },
      "url" => %{
        "full" => "https://anonfiles.com/O80cxd2ayd/039_08-06-22_B2_Opt_Sociology_5pm_to_8pm_mp4",
        "short" => "https://anonfiles.com/O80cxd2ayd"
      }
    }
  },
  "status" => true
  }

  """
  def info(url) do
    file_id =
      url
      |> String.split("://")
      |> Enum.at(1)
      |> String.split("/")
      |> Enum.at(1)

    path = "/v2/file/#{file_id}/info"
    full_path = (@base_url <> path) |> IO.inspect(label: "full_path")

    HTTPoison.get(full_path)
    |> autoretry(max_attempts: 5, wait: 1500, include_404s: true, retry_unknown_errors: true)
    |> handle_result_json()
  end

  def download_page(url) do
    HTTPoison.get(url)
    |> autoretry(max_attempts: 5, wait: 1500, include_404s: true, retry_unknown_errors: true)
    |> handle_html()
  end

  def with_extension(filename) do
    extension =
      filename
      |> String.split("_")
      |> List.last()

    extension_list = ["mp4", "pdf", "mp3", "jpeg", "jpg", "png", "gif"]

    if(extension in extension_list) do
      filename <> "_even_bot." <> extension
    else
      filename
    end
  end
end
