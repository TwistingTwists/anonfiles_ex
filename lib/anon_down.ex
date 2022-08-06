defmodule AnonDown do
  @moduledoc """
  Documentation for `AnonDown`.
  """
  @base_url "https://api.filechan.org"

  import HTTPoison.Retry
  import HTTP.API

  def download(url, timeout \\ 120_000, retries_count \\ 5, base_url \\ @base_url) do
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
    } = info(url, base_url)

    IO.inspect("#{retries_count} -> trying url -> #{full_url}\n")

    case download_page(full_url) |> IO.inspect(label: "download_page") do
      {:ok, cdn_url} ->
        do_download(%{
          url: url,
          cdn_url: cdn_url,
          file_name: file_name,
          timeout: timeout,
          retries_count: retries_count,
          status: status
        })

      {:error, reason} ->
        IO.inspect(label: "no cdn_url#{inspect(reason)}")
        ""
    end
  end

  def do_download(
        %{
          url: url,
          cdn_url: cdn_url,
          file_name: file_name,
          timeout: timeout,
          retries_count: retries_count,
          status: status
        } = _opts
      ) do
    if(status) do
      filename_with_extension =
        file_name |> with_extension() |> IO.inspect(label: "filename_with_extension")

      file = File.open!(filename_with_extension, [:write])

      http_poison_opts = [
        headers: [{"Accept", "application/json"}, {"User-Agent", "AnonDown"}],
        timeout: timeout
      ]

      case Downstream.get(cdn_url, file, http_poison_opts) do
        {:ok, file} ->
          {:ok, filename_with_extension}

        {:error, err} ->
          :timer.sleep(15000)

          if retries_count > 0 do
            IO.inspect("got - #{inspect(err)} \n")
            download(url, :infinity, retries_count - 1)
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
  def info(url, base_url) do
    file_id =
      url
      |> String.split("://")
      |> Enum.at(1)
      |> String.split("/")
      |> Enum.at(1)

    path = "/v2/file/#{file_id}/info"
    full_path = (base_url <> path) |> IO.inspect(label: "full_path")

    HTTPoison.get(full_path)
    |> autoretry(max_attempts: 5, wait: 10_000, include_404s: true, retry_unknown_errors: true)
    |> handle_result_json()
  end

  def download_page(url) do
    HTTPoison.get(url)
    |> autoretry(max_attempts: 5, wait: 10_000, include_404s: true, retry_unknown_errors: true)
    |> handle_html()
  end

  def with_extension(filename) do
    extension =
      filename
      |> String.split("_")
      |> List.last()
      |> String.trim()

    # extension_list = ["mp4", "pdf", "mp3", "jpeg", "jpg", "png", "gif"]

    # if(extension in extension_list) do
    filename <> "_even_bot." <> extension
    # else
    #   filename
    # end
  end

  # def get_base-url
end
