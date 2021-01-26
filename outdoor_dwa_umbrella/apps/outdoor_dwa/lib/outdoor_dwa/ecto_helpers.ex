defmodule OutdoorDwa.EctoHelpers do
  import Ecto.Changeset

  @spec put_hash(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  def put_hash(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  def put_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, Pbkdf2.add_hash(password))
  end

  @spec validate_password(String.t(), String.t()) :: Struct.t() | Map.t() | false
  def validate_password(user, password) do
    case Pbkdf2.check_pass(user, password) do
      {:ok, user} ->
        user

      _ ->
        false
    end
  end
end
