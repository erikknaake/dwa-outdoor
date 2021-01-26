defmodule OutdoorDwa.UserContext.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias OutdoorDwa.EditionUserRoleContext.EditionUserRole
  alias OutdoorDwa.TeamContext.Team
  alias OutdoorDwa.EctoHelpers

  @required_fields ~w(name password password_confirmation)a
  @optional_fields ~w(is_admin)a
  @all_fields @required_fields ++ @optional_fields
  schema "users" do
    field :name, :string
    field :password_hash, :string
    field :is_admin, :boolean, default: false

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :user_role, EditionUserRole
    has_many :team, Team
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @all_fields)
    |> validate_confirmation(:password)
    |> validate_required(@required_fields)
    |> EctoHelpers.put_hash()
    |> unique_constraint(:unique_user_name, name: :unique_user_name)
  end
end
