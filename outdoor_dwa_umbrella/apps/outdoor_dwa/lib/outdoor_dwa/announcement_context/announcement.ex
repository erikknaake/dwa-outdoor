defmodule OutdoorDwa.AnnouncementContext.Announcement do
  use Ecto.Schema
  import Ecto.Changeset

  schema "announcement" do
    field :announcement, :string
    belongs_to :edition, Edition

    timestamps()
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, [:announcement, :edition_id])
    |> validate_required([:announcement])
  end
end
