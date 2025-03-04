defmodule Beacon.Stylesheets.Stylesheet do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stylesheets" do
    field(:content, :string)
    field(:name, :string)
    field(:site, :string)

    timestamps()
  end

  @doc false
  def changeset(stylesheet, attrs) do
    stylesheet
    |> cast(attrs, [:name, :content, :site])
    |> validate_required([:name, :content, :site])
  end
end
