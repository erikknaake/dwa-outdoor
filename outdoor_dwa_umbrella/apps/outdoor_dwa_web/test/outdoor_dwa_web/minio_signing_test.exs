defmodule OutdoorDwaWeb.MinioSigningTest do
  use ExUnit.Case, async: true

  alias OutdoorDwaWeb.MinioSigning

  @doc """
  Example data generated with NodeJs minio SDK
  """
  test "Covert config to signed post form" do
    config = %{
      expire_seconds: 24 * 60 * 60 * 10,
      object: "test.png",
      bucket: "uploads",
      region: "us-east-1",
      access_key_id: "minio",
      secret_key: "minio123",
      host: "localhost",
      port: 9000,
      protocol: "http"
    }

    {:ok, date_time, 0} = DateTime.from_iso8601("2020-11-20T22:39:22.408Z")

    expected = %{
      postURL: "http://localhost:9000/uploads",
      formData: %{
        "key" => "test.png",
        "bucket" => "uploads",
        "x-amz-date" => "20201120T223922Z",
        "x-amz-algorithm" => "AWS4-HMAC-SHA256",
        "x-amz-credential" => "minio/20201120/us-east-1/s3/aws4_request",
        "policy" =>
          "eyJjb25kaXRpb25zIjpbWyJlcSIsIiRrZXkiLCJ0ZXN0LnBuZyJdLFsiZXEiLCIkYnVja2V0IiwidXBsb2FkcyJdLFsiY29udGVudC1sZW5ndGgtcmFuZ2UiLDAsMjA5NzE1MjAwXSxbImVxIiwiJHgtYW16LWRhdGUiLCIyMDIwMTEyMFQyMjM5MjJaIl0sWyJlcSIsIiR4LWFtei1hbGdvcml0aG0iLCJBV1M0LUhNQUMtU0hBMjU2Il0sWyJlcSIsIiR4LWFtei1jcmVkZW50aWFsIiwibWluaW8vMjAyMDExMjAvdXMtZWFzdC0xL3MzL2F3czRfcmVxdWVzdCJdXSwiZXhwaXJhdGlvbiI6IjIwMjAtMTEtMzBUMjI6Mzk6MDAuNDA4WiJ9",
        "x-amz-signature" => "db73f860d7dcc3ac96c79b98dcb4989834c1b0a78271694586dd17366af267aa"
      }
    }

    actual = MinioSigning.pre_signed_post_policy(config, date_time)
    assert actual == expected
  end

  @doc """
  Example data generated with NodeJs minio SDK
  """
  test "Convert config to presigned download url" do
    config = %{
      expire_seconds: 24 * 60 * 60,
      object: "dodgebow2.JPG",
      bucket: "uploads",
      region: "us-east-1",
      access_key_id: "minio",
      secret_key: "minio123",
      host: "localhost",
      port: 9000,
      protocol: "http"
    }

    {:ok, date_time, 0} = DateTime.from_iso8601("2020-11-23T09:07:34.223Z")

    expected =
      "http://localhost:9000/uploads/dodgebow2.JPG?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=minio%2F20201123%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20201123T090734Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=85e2bc175cb85ded4ef9584d188bd433bc43d43d66e6e47baa598c8bba7bb132"

    actual = MinioSigning.pre_signed_get_url(config, date_time)
    assert actual == expected
  end
end
