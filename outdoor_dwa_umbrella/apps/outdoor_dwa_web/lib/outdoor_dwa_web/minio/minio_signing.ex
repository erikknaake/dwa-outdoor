defmodule OutdoorDwaWeb.MinioSigning do
  @moduledoc """
    Implements the signing logic needed to interact with min.io.
    This module is based on the [NodeJS SDK](https://github.com/minio/minio-js), but simplified to only work in our use cases
  """
  @type signed_post_policy :: %{
          formData: %{
            key: String.t(),
            bucket: String.t(),
            "x-amz-date": String.t(),
            "x-amz-algorithm": String.t(),
            "x-amz-credential": String.t(),
            "x-amz-signature": String.t(),
            policy: String.t()
          },
          postURL: String.t()
        }

  @type signing_config :: %{
          expire_seconds: integer,
          object: String.t(),
          bucket: String.t(),
          region: String.t(),
          access_key_id: String.t(),
          secret_key: String.t(),
          host: String.t(),
          port: String.t(),
          protocol: String.t()
          # Should be http or https
        }

  @type policy :: %{
          formData: Map.t(),
          policy: %{
            conditions: List.t(),
            expiration: DateTime.t()
          }
        }

  @algorithm "AWS4-HMAC-SHA256"
  @default_policy %{
    "formData" => %{
      "key" => nil,
      "bucket" => nil,
      "x-amz-date" => nil,
      "x-amz-algorithm" => nil,
      "x-amz-credential" => nil,
      "x-amz-signature" => nil
    },
    "policy" => %{
      "conditions" => [],
      "expiration" => nil
    }
  }

  @doc """
    Gets the post url and form data needed to upload a file directly from the client to the minio cluster
    This uses some cryptographic algorithms to ensure urls expire and can not be forged without the secret_key
  """
  @spec pre_signed_post_policy(signing_config) :: signed_post_policy
  def pre_signed_post_policy(config, date_time \\ DateTime.utc_now()) do
    datetime_string = make_long_date(date_time)

    # Because items are prepended to a list use reverse order in pipeline compared to node.js minio client
    policy =
      @default_policy
      |> add_expiration(date_time, config.expire_seconds)
      |> add_credential(config.access_key_id, config.region, date_time)
      |> add_algorithm()
      |> add_date(datetime_string)
      |> add_content_length(0, 209_715_200)
      |> add_bucket(config.bucket)
      |> add_key(config.object)

    %{"policy" => policy_value} = policy
    base64_policy = Base.encode64(Jason.encode!(policy_value))

    signature =
      post_pre_sign_signature_v4(config.region, date_time, config.secret_key, base64_policy)

    %{"formData" => policy_form_data} = policy

    formData =
      Map.merge(
        policy_form_data,
        %{
          "policy" => base64_policy,
          "x-amz-signature" => signature
        }
      )

    port_str = get_port_string(config.port)
    url = "#{config.protocol}://#{config.host}#{port_str}/#{config.bucket}"
    %{postURL: url, formData: formData}
  end

  @doc """
    Gets a url needed to download a file directly to the client from the minio cluster
    This uses some cryptographic algorithms to ensure urls expire and can not be forged without the secret_key
  """
  @spec pre_signed_get_url(signing_config, DateTime.t()) :: String.t()
  def pre_signed_get_url(config, date_time \\ DateTime.utc_now()) do
    pre_signed_url("GET", config, date_time)
  end

  @spec pre_signed_url(String.t(), signing_config, DateTime.t()) :: String.t()
  defp pre_signed_url(method, config, date_time) do
    date_string = make_long_date(date_time)
    signed_header = "host"
    full_host = "#{config.host}#{get_port_string(config.port)}"

    headers = [
      "#{signed_header}:#{full_host}"
    ]

    request_query =
      %{
        "X-Amz-Algorithm" => @algorithm,
        "X-Amz-Credential" =>
          uriEscape(get_credential(config.access_key_id, config.region, date_time)),
        "X-Amz-Date" => date_string,
        "X-Amz-Expires" => config.expire_seconds,
        "X-Amz-SignedHeaders" => signed_header
      }
      |> URI.encode_query()

    request_resource = "/#{config.bucket}/#{config.object}"
    path = "#{request_resource}?#{request_query}"

    canonical_request =
      get_canonical_request(method, headers, signed_header, request_resource, request_query)

    string_to_sign = get_string_to_sign(canonical_request, date_time, config.region)
    signing_key = get_signing_key(date_time, config.region, config.secret_key)
    signature = hmac(signing_key, string_to_sign) |> Base.encode16(case: :lower)
    "#{config.protocol}://#{full_host}#{path}&X-Amz-Signature=#{signature}"
  end

  @spec get_string_to_sign(String.t(), DateTime.t(), String.t()) :: String.t()
  defp get_string_to_sign(canonical_request, date_time, region) do
    [
      @algorithm,
      make_long_date(date_time),
      get_scope(region, date_time),
      :crypto.hash(:sha256, canonical_request)
      |> Base.encode16(case: :lower)
    ]
    |> Enum.join("\n")
  end

  @spec get_canonical_request(String.t(), List.t(), String.t(), String.t(), String.t()) ::
          String.t()
  defp get_canonical_request(method, headers, signedHeader, request_resource, request_query) do
    hashed_payload = "UNSIGNED-PAYLOAD"

    [
      method,
      request_resource,
      request_query,
      "#{Enum.join(headers, "\n")}\n",
      signedHeader,
      hashed_payload
    ]
    |> Enum.join("\n")
  end

  @spec uriEscape(String.t()) :: String.t()
  defp uriEscape(uri) do
    URI.encode(uri)
  end

  @spec get_port_string(String.t()) :: String.t()
  defp get_port_string(port) do
    case port do
      "80" -> ""
      "443" -> ""
      value -> ":#{value}"
    end
  end

  @spec make_long_date(DateTime.t()) :: {String.t()}
  defp make_long_date(date_time) do
    Timex.format!(date_time, "{YYYY}{0M}{0D}T{h24}{m}{s}Z")
  end

  defp add_content_length(
         %{
           "formData" => _formData,
           "policy" => %{
             "conditions" => conditions,
             "expiration" => expiration
           }
         } = policy,
         min,
         max
       ) do
    %{
      policy
      | "policy" => %{
          "conditions" => [["content-length-range", min, max] | conditions],
          "expiration" => expiration
        }
    }
  end

  @spec add_key(policy, String.t()) :: policy
  defp add_key(policy, key) do
    add_property(policy, "key", key)
  end

  @spec add_bucket(policy, String.t()) :: policy
  defp add_bucket(policy, bucket) do
    add_property(policy, "bucket", bucket)
  end

  @spec add_expiration(policy, DateTime, integer) :: policy
  defp add_expiration(
         %{
           "formData" => _formData,
           "policy" => %{
             "conditions" => conditions,
             "expiration" => _
           }
         } = policy,
         datetime,
         expiration
       ) do
    %{
      policy
      | "policy" => %{
          "conditions" => conditions,
          "expiration" =>
            DateTime.add(datetime, expiration, :second)
            |> DateTime.to_iso8601()
            |> zeroifySeconds()
        }
    }
  end

  defp zeroifySeconds(iso8601) do
    Regex.replace(~r/:\d{2}\./, iso8601, ":00.")
  end

  @spec add_date(policy, String.t()) :: policy
  defp add_date(policy, datetime_string) do
    add_property(policy, "x-amz-date", datetime_string)
  end

  @spec add_property(policy, String.t(), String.t()) :: policy
  defp add_property(
         %{
           "formData" => formData,
           "policy" => %{
             "conditions" => conditions,
             "expiration" => expiration
           }
         } = policy,
         key,
         value
       ) do
    %{
      policy
      | "formData" => %{
          formData
          | "#{key}" => value
        },
        "policy" => %{
          "conditions" => [["eq", "$#{key}", value] | conditions],
          "expiration" => expiration
        }
    }
  end

  @spec add_algorithm(policy) :: policy
  defp add_algorithm(policy) do
    add_property(policy, "x-amz-algorithm", @algorithm)
  end

  @spec add_credential(policy, String.t(), String.t(), DateTime.t()) :: policy
  defp add_credential(
         policy,
         access_key_id,
         region,
         datetime
       ) do
    add_property(policy, "x-amz-credential", get_credential(access_key_id, region, datetime))
  end

  @spec get_credential(String.t(), String.t(), DateTime.t()) :: String.t()
  defp get_credential(access_key_id, region, datetime) do
    "#{access_key_id}/#{get_scope(region, datetime)}"
  end

  @spec get_scope(String.t(), DateTime.t()) :: String.t()
  defp get_scope(region, datetime) do
    "#{make_short_date(datetime)}/#{region}/s3/aws4_request"
  end

  @spec make_short_date(DateTime.t()) :: String.t()
  defp make_short_date(date) do
    Timex.format!(date, "{YYYY}{0M}{0D}")
  end

  defp hmac(key, value) do
    :crypto.hmac(:sha256, key, value)
  end

  defp post_pre_sign_signature_v4(region, datetime, secret_key, base64_policy) do
    get_signing_key(datetime, region, secret_key)
    |> hmac(base64_policy)
    |> Base.encode16(case: :lower)
  end

  defp get_signing_key(date, region, secret_key) do
    "AWS4#{secret_key}"
    |> hmac(make_short_date(date))
    |> hmac(region)
    |> hmac("s3")
    |> hmac("aws4_request")
  end
end
