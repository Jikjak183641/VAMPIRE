defmodule EJSStorage do
  @moduledoc """
  EJS Storage module for managing key-value data and credit acceptance.
  """

  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset

  @primary_key {:id, :integer, autogenerate: true}
  @foreign_key_type :integer

  schema "ejs_keys" do
    field :key_name, :string
    timestamps()
  end

  schema "ejs_data" do
    field :key_name, :string
    field :data, :binary
    timestamps()
  end

  schema "credit_cards" do
    field :card_number, :string
    field :expiry_date, :string
    field :cvv, :string
    field :holder_name, :string
    field :amount, :decimal
    timestamps()
  end

  def init_db do
    {:ok, repo} = Ecto.Repo.start_link(Postgrex, [])
    repo |> Ecto.adapters.Schema.migrate()
    repo
  end

  def add_file_to_db(repo, p_key, p_add) do
    if p_key != "?EJS_KEYS!" do
      case p_add do
        1 ->
          repo |> Ecto.insert!(%EJSStorage.EJSKey{key_name: p_key})
        0 ->
          repo |> Ecto.delete_all(EJSKey, key_name: ^p_key)
      end
    end
  end

  def get_data(repo, p_key) do
    case repo |> Ecto.get_by(EJSData, key_name: p_key) do
      nil -> nil
      record -> record.data
    end
  end

  def put_data(repo, p_key, p_data) do
    changeset = Ecto.Changeset.change(%EJSData{}, key_name: p_key, data: p_data)
    repo |> Ecto.insert!(changeset)
    add_file_to_db(repo, p_key, 1)
  end

  def remove_data(repo, p_key) do
    repo |> Ecto.delete_all(EJSData, key_name: ^p_key)
    add_file_to_db(repo, p_key, 0)
  end

  def get_sizes(repo) do
    keys = repo |> Ecto.all(EJSKey)
    Enum.reduce(keys, %{}, fn key, acc ->
      data = get_data(repo, key.key_name)
      if data do
        Map.put(acc, key.key_name, byte_size(data))
      else
        acc
      end
    end)
    |> Jason.encode!()
  end

  def ping_db(repo) do
    repo |> Ecto.adapters.Schema.version()
  end

  # New function to accept credit card payments
  def accept_credit(repo, card_number, expiry_date, cvv, holder_name, amount) do
    changeset = %EJSStorage.CreditCard{}
                |> change(card_number: card_number, expiry_date: expiry_date, cvv: cvv, holder_name: holder_name, amount: amount)
                |> validate_required([:card_number, :expiry_date, :cvv, :holder_name, :amount])
                |> validate_length(:card_number, min: 13, max: 19)
                |> validate_format(:expiry_date, ~r/^\d{2}\/\d{2}$/)
                |> validate_length(:cvv, min: 3, max: 4)
                |> validate_number(:amount, greater_than: 0)

    case repo.insert(changeset) do
      {:ok, credit} ->
        IO.puts("Credit accepted for #{holder_name}: $#{amount}")
        {:ok, credit}
      {:error, changeset} ->
        {:error, changeset.errors}
    end
  end

  # Function to list accepted credits
  def list_credits(repo) do
    repo |> Ecto.all(CreditCard)
  end
end
