defmodule ResourceManager.Identities.Schemas.ClientApplication do
  @moduledoc """
  The application is a resource and a subject that makes requests through the systems.

  We do not save application private keys, only the public one.
  """

  use ResourceManager.Schema

  import Ecto.Changeset

  alias ResourceManager.Credentials.Schemas.PublicKey
  alias ResourceManager.Permissions.Schemas.Scope
  alias ResourceManager.Ports.Authenticator

  @typedoc "User schema fields"
  @type t :: %__MODULE__{
          id: binary(),
          client_id: String.t(),
          name: String.t(),
          description: String.t(),
          status: String.t(),
          protocol: String.t(),
          access_type: String.t(),
          is_admin: boolean(),
          grant_flows: list(String.t()),
          public_key: PublicKey.t(),
          scopes: Scope.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @possible_statuses ~w(active inactive blocked)
  @possible_protocols ~w(openid-connect)
  @possible_access_types ~w(confidential public bearer-only)
  @possible_grant_flows ~w(resource_owner implicit client_credentials refresh_token authorization_code)

  @required_fields [:name, :status, :protocol, :access_type]
  @optional_fields [:grant_flows, :description, :redirect_uri, :blocked_until]
  schema "client_applications" do
    field :client_id, Ecto.UUID, autogenerate: true
    field :name, :string
    field :description, :string
    field :status, :string, default: "active"
    field :blocked_until, :naive_datetime
    field :protocol, :string, default: "openid-connect"
    field :access_type, :string, default: "confidential"
    field :is_admin, :boolean, default: false
    field :grant_flows, {:array, :string}
    field :redirect_uri, :string
    field :secret, :string

    has_one :public_key, PublicKey
    many_to_many :scopes, Scope, join_through: "client_applications_scopes"

    timestamps()
  end

  @doc false
  def changeset_create(params) when is_map(params) do
    %__MODULE__{}
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:name, min: 1, max: 150)
    |> validate_inclusion(:status, @possible_statuses)
    |> validate_inclusion(:protocol, @possible_protocols)
    |> validate_inclusion(:access_type, @possible_access_types)
    |> validate_subset(:grant_flows, @possible_grant_flows)
    |> unique_constraint(:name)
    |> generate_secret()
  end

  defp generate_secret(%{valid?: false} = changeset), do: changeset

  defp generate_secret(changeset) do
    secret = Authenticator.generate_hash(Ecto.UUID.generate(), :bcrypt)
    put_change(changeset, :secret, secret)
  end

  @doc false
  def changeset_update(%__MODULE__{} = model, params) when is_map(params) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_length(:name, min: 1, max: 150)
    |> validate_inclusion(:status, @possible_statuses)
    |> validate_inclusion(:protocol, @possible_protocols)
    |> validate_inclusion(:access_type, @possible_access_types)
    |> validate_subset(:grant_flows, @possible_grant_flows)
    |> unique_constraint(:name)
  end

  @doc false
  def possible_statuses, do: @possible_statuses

  @doc false
  def possible_protocols, do: @possible_protocols

  @doc false
  def possible_access_types, do: @possible_access_types

  @doc false
  def possible_grant_flows, do: @possible_grant_flows

  #################
  # Custom filters
  #################

  defp custom_query(query, {:client_ids, client_ids}),
    do: where(query, [c], c.client_id in ^client_ids)

  defp custom_query(query, {:blocked_after, date}),
    do: where(query, [c], c.blocked_until > ^date)

  defp custom_query(query, {:blocked_before, date}),
    do: where(query, [c], c.blocked_until < ^date)
end
