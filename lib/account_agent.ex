defmodule AccountAgent do
  use Agent

  alias Structs.Account

  # {:ok, pid} = AccountAgent.start_link([])
  # AccountAgent.create_account(pid, "Test", "USD")
  # AccountAgent.add_balance(pid, 1, 100)
  # AccountAgent.get_balance(pid, 1)
  # AccountAgent.reduce_balance(pid, 1, 50)
  def start_link(_) do
    IO.puts("Starting AccountAgent")
    Agent.start_link(fn -> %{accounts: %{}, account_id: 0} end, name: __MODULE__)
  end

  def create_account(agent, name, currency) do
    Agent.get_and_update(agent, fn state ->
      account_id = state.account_id + 1

      new_account = %Account{
        account_id: account_id,
        name: name,
        balance: 0,
        currency: currency
      }

      updated_accounts = Map.put(state.accounts, account_id, new_account)
      updated_state = %{state | accounts: updated_accounts, account_id: account_id}
      {new_account, updated_state}
    end)
  end

  def get_accounts(agent) do
    Agent.get(agent, fn state ->
      state.accounts
    end)
  end

  def get_account(agent, account_id) do
    Agent.get(agent, fn state ->
      Map.get(state.accounts[account_id], %{})
    end)
  end

  def add_balance(agent, account_id, balance) do
    Agent.get_and_update(agent, fn state ->
      account = Map.get(state.accounts, account_id)

      if account do
        new_balance = account.balance + balance
        updated_account = %{account | balance: new_balance}
        updated_accounts = Map.put(state.accounts, account_id, updated_account)
        updated_state = %{state | accounts: updated_accounts}
        {updated_account, updated_state}
      else
        {{:error, "Account not found"}, state}
      end
    end)
  end

  def get_balance(agent, account_id) do
    Agent.get(agent, fn state ->
      account = Map.get(state.accounts, account_id)

      if account,
        do: account.balance,
        else: {:error, "Account not found"}
    end)
  end

  def reduce_balance(agent, account_id, amount) do
    Agent.update(agent, fn state ->
      account = Map.get(state.accounts, account_id)

      if account do
        new_balance = account.balance - amount
        updated_account = %{account | balance: new_balance}
        updated_accounts = Map.put(state.accounts, account_id, updated_account)
        %{state | accounts: updated_accounts}
      else
        {{:error, "Account not found"}, state}
      end
    end)
  end
end
