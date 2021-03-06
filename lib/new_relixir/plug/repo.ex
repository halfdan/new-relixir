defmodule NewRelixir.Plug.Repo do
  @moduledoc """
  Defines a module that provides instrumented methods for a standard `Ecto.Repo`.

  ```
  defmodule MyApp.Repo do
    use Ecto.Repo, otp_application: :my_app

    defmodule NewRelic do
      use NewRelixir.Plug.Repo, repo: MyApp.Repo
    end
  end
  ```

  Anywhere that the original repository is used to make a database call, the
  wrapper module can be used instead. For example, `MyApp.Repo.all(User)` can
  be replaced with `MyApp.Repo.NewRelic.all(User)`. These database calls must
  be done in the scope of an instrumented Phoenix controller or Plug endpoint.
  Calls made from spawned child subprocesses are supported.
  """

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      repo = Keyword.fetch!(opts, :repo)
      @repo repo

      import NewRelixir.Plug.Instrumentation

      @spec transaction(Keyword.t, fun) :: {:ok, any} | {:error, any}
      def transaction(opts \\ [], fun) when is_list(opts) do
        repo().transaction(opts, fun)
      end

      @spec rollback(any) :: no_return
      def rollback(value) do
        repo().rollback(value)
      end

      @spec all(Ecto.Query.t, Keyword.t) :: [Ecto.Schema.t] | no_return
      def all(queryable, opts \\ []) do
        instrument_db(:all, queryable, opts, fn() ->
          repo().all(queryable, opts)
        end)
      end

      @spec get(Ecto.Queryable.t, term, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get(queryable, id, opts \\ []) do
        instrument_db(:get, queryable, opts, fn() ->
          repo().get(queryable, id, opts)
        end)
      end

      @spec get!(Ecto.Queryable.t, term, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get!(queryable, id, opts \\ []) do
        instrument_db(:get!, queryable, opts, fn() ->
          repo().get!(queryable, id, opts)
        end)
      end

      @spec get_by(Ecto.Queryable.t, Keyword.t | Map.t, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get_by(queryable, clauses, opts \\ []) do
        instrument_db(:get_by, queryable, opts, fn() ->
          repo().get_by(queryable, clauses, opts)
        end)
      end

      @spec get_by!(Ecto.Queryable.t, Keyword.t | Map.t, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def get_by!(queryable, clauses, opts \\ []) do
        instrument_db(:get_by!, queryable, opts, fn() ->
          repo().get_by!(queryable, clauses, opts)
        end)
      end

      @spec one(Ecto.Queryable.t, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def one(queryable, opts \\ []) do
        instrument_db(:one, queryable, opts, fn() ->
          repo().one(queryable, opts)
        end)
      end

      @spec one!(Ecto.Queryable.t, Keyword.t) :: Ecto.Schema.t | nil | no_return
      def one!(queryable, opts \\ []) do
        instrument_db(:one!, queryable, opts, fn() ->
          repo().one!(queryable, opts)
        end)
      end


      @spec insert_all(schema_or_source :: binary | {binary, Ecto.Schema.t} | Ecto.Schema.t,
        entries :: [map | Keyword.t], opts :: Keyword.t) :: {integer, nil | [term]} | no_return
      def insert_all(schema_or_source, entries, opts \\ []) do
        instrument_db(:insert_all, schema_or_source, opts, fn() ->
          repo().insert_all(schema_or_source, entries, opts)
        end)
      end

      @spec update_all(Macro.t, Keyword.t, Keyword.t) :: {integer, nil} | no_return
      def update_all(queryable, updates, opts \\ []) do
        instrument_db(:update_all, queryable, opts, fn() ->
          repo().update_all(queryable, updates, opts)
        end)
      end

      @spec delete_all(Ecto.Queryable.t, Keyword.t) :: {integer, nil} | no_return
      def delete_all(queryable, opts \\ []) do
        instrument_db(:delete_all, queryable, opts, fn() ->
          repo().delete_all(queryable, opts)
        end)
      end

      @spec insert(Ecto.Schema.t | Ecto.Changeset.t, Keyword.t) :: {:ok, Ecto.Schema.t} | {:error, Ecto.Changeset.t}
      def insert(model, opts \\ []) do
        instrument_db(:insert, model, opts, fn() ->
          repo().insert(model, opts)
        end)
      end

      @spec update(Ecto.Changeset.t, Keyword.t) :: {:ok, Ecto.Schema.t} | {:error, Ecto.Changeset.t}
      def update(model, opts \\ []) do
        instrument_db(:update, model, opts, fn() ->
          repo().update(model, opts)
        end)
      end

      @spec insert_or_update(Ecto.Changeset.t, Keyword.t) :: {:ok, Ecto.Schema.t} | {:error, Ecto.Changeset.t}
      def insert_or_update(changeset, opts \\ []) do
        instrument_db(:insert_or_update, changeset, opts, fn() ->
          repo().insert_or_update(changeset, opts)
        end)
      end

      @spec delete(Ecto.Schema.t, Keyword.t) :: {:ok, Ecto.Schema.t} | {:error, Ecto.Changeset.t}
      def delete(model, opts \\ []) do
        instrument_db(:delete, model, opts, fn() ->
          repo().delete(model, opts)
        end)
      end

      @spec insert!(Ecto.Schema.t, Keyword.t) :: Ecto.Schema.t | no_return
      def insert!(model, opts \\ []) do
        instrument_db(:insert!, model, opts, fn() ->
          repo().insert!(model, opts)
        end)
      end

      @spec update!(Ecto.Schema.t, Keyword.t) :: Ecto.Schema.t | no_return
      def update!(model, opts \\ []) do
        instrument_db(:update!, model, opts, fn() ->
          repo().update!(model, opts)
        end)
      end

      @spec insert_or_update!(Ecto.Changeset.t, Keyword.t) :: Ecto.Schema.t | no_return
      def insert_or_update!(changeset, opts \\ []) do
        instrument_db(:insert_or_update!, changeset, opts, fn() ->
          repo().insert_or_update!(changeset, opts)
        end)
      end

      @spec delete!(Ecto.Schema.t, Keyword.t) :: Ecto.Schema.t | no_return
      def delete!(model, opts \\ []) do
        instrument_db(:delete!, model, opts, fn() ->
          repo().delete!(model, opts)
        end)
      end

      @spec aggregate(Ecto.Queryable.t, :avg | :count | :max | :min | :sum, atom, Keyword.t) :: term | nil
      def aggregate(queryable, aggregate, field, opts \\ []) do
        instrument_db(:aggregate, queryable, opts, fn() ->
          repo().aggregate(queryable, aggregate, field, opts)
        end)
      end

      @spec preload([Ecto.Schema.t] | Ecto.Schema.t, preloads :: term) :: [Ecto.Schema.t] | Ecto.Schema.t
      def preload(model_or_models, preloads, opts \\ []) do
        instrument_db(:preload, model_or_models, opts, fn() ->
          repo().preload(model_or_models, preloads)
        end)
      end

      @spec repo :: Ecto.Repo.t
      defp repo do
        @repo
      end
    end
  end
end
