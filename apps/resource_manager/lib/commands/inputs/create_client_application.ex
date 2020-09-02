defmodule ResourceManager.Commands.Inputs.CreateClientApplication do
  @moduledoc """
  Input parameters for creating client applications
  """

  use ResourceManager.Input

  alias ResourceManager.Identity.Schemas.ClientApplication

  @typedoc "Create client application input fields"
  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          public_key: String.t(),
          status: String.t() | nil,
          protocol: String.t() | nil,
          access_type: String.t() | nil,
          scopes: list(String.t()) | nil
        }

  @required [:name, :public_key]
  @optional [:description, :status, :protocol, :access_type, :scopes]
  embedded_schema do
    field :name, :string
    field :description, :string
    field :public_key, :string
    field :status, :string
    field :protocol, :string
    field :access_type, :string
    field :scopes, {:array, :string}
  end

  @doc false
  def cast_and_apply(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, @required ++ @optional)
    |> validate_length(:name, min: 1, max: 150)
    |> validate_length(:public_key, min: 1, max: 150)
    |> validate_inclusion(:status, ClientApplication.possible_statuses())
    |> validate_inclusion(:protocol, ClientApplication.possible_protocols())
    |> validate_inclusion(:access_type, ClientApplication.possible_access_types())
    |> validate_required(@required)
  end
end
