defmodule OutdoorDwa.EditionUserRoleContext.EditionUserRole do
  use Ecto.Schema
  import Ecto.Changeset

  alias OutdoorDwa.UserContext.User
  alias OutdoorDwa.EditionContext.Edition

  schema "edition_user_role" do
    field :role, :string
    belongs_to :user, User
    belongs_to :edition, Edition
  end

  @doc false
  def changeset(edition__user_role, attrs \\ %{}) do
    edition__user_role
    |> cast(attrs, [])
    |> cast_assoc(:edition)
    |> cast_assoc(:user)
    |> validate_required([])
  end
end
