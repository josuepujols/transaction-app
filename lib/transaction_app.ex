defmodule TransactionApp do
  use GenServer
  alias Structs.Transaction

  # Client API

  def start_link(_) do
    IO.puts("Starting TransactionApp")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_agent() do
    GenServer.call(__MODULE__, :get_agent)
  end

  def make_transaction(account_id, target_account_id, amount) do
    args = %{
      account_id: account_id,
      target_account_id: target_account_id,
      amount: amount
    }

    GenServer.cast(__MODULE__, {:make_transaction, args})
  end

  def get_transactions() do
    GenServer.call(__MODULE__, :get_transactions)
  end

  def get_transaction(transaction_id) do
    GenServer.call(__MODULE__, {:get_transaction, transaction_id})
  end

  # Callbacks
  @impl true
  def init(_args) do
    :ets.new(:transactions, [:set, :private, :named_table])
    {:ok, pid} = AccountAgent.start_link([])
    {:ok, %{agent: pid, transaction_id: 0}}
  end

  @impl true
  def handle_call(:get_agent, _from, state) do
    {:reply, state.agent, state}
  end

  @impl true
  def handle_call(:get_transactions, _from, state) do
    {:reply, :ets.tab2list(:transactions), state}
  end

  @impl true
  def handle_call({:get_transaction, transaction_id}, _from, state) do
    {:reply, :ets.lookup(:transactions, transaction_id), state}
  end

  @impl true
  def handle_cast(
        {:make_transaction,
         %{account_id: account_id, target_account_id: target_account_id, amount: amount}},
        state
      ) do
    # Get account balance to know if the transaction can be made
    balance_account = AccountAgent.get_balance(state.agent, account_id)

    if balance_account >= amount do
      # Update the account balance
      AccountAgent.reduce_balance(state.agent, account_id, amount)
      AccountAgent.add_balance(state.agent, target_account_id, amount)
      transaction_id = state.transaction_id + 1

      # Save the transaction
      transaction = %Transaction{
        transaction_id: transaction_id,
        account_id: account_id,
        destination_account_id: target_account_id,
        amount: amount,
        timestamp: DateTime.utc_now()
      }

      IO.puts("Transaction successful: #{inspect(transaction)}")
      :ets.insert(:transactions, {transaction_id, transaction})
      {:noreply, %{state | transaction_id: transaction_id}}
    else
      IO.puts("Transaction failed: Insufficient funds in account #{account_id}")
      {:noreply, state}
    end
  end
end
