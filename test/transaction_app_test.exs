defmodule TransactionAppTest do
  use ExUnit.Case, async: true
  doctest TransactionApp

  setup do
    # Start a supervised instance of TransactionApp
    transaction_app = start_supervised!(TransactionApp)

    # Get the agent from the TransactionApp
    agent = TransactionApp.get_agent()

    {:ok, %{agent: agent, transaction_app: transaction_app}}
  end

  test "Creating an account should return the account struct", %{agent: agent} do
    account = AccountAgent.create_account(agent, "Test", "USD")

    assert %Structs.Account{
             account_id: _,
             name: "Test",
             balance: 0,
             currency: "USD"
           } = account
  end

  test "Adding balance to an account should return the account with the new balance", %{agent: agent} do
    account = AccountAgent.create_account(agent, "Test", "USD")

    account_with_balance = AccountAgent.add_balance(agent, account.account_id, 100)
    assert %Structs.Account{
             account_id: _,
             name: "Test",
             balance: 100,
             currency: "USD"
           } = account_with_balance
  end

  test "Reducing balance to an account should return the account with the new balance", %{agent: agent} do
    account = AccountAgent.create_account(agent, "Test", "USD")

    AccountAgent.add_balance(agent, account.account_id, 500)
    AccountAgent.reduce_balance(agent, account.account_id, 200)
    new_balance = AccountAgent.get_balance(agent, account.account_id)

    assert 300 = new_balance
  end

  test "Making a transaction should save the transaction", %{agent: agent} do
    #  Create two accounts
    account_1 = AccountAgent.create_account(agent, "Account 2", "USD")
    account_2 = AccountAgent.create_account(agent, "account 2", "USD")

    # Add balance to both accounts
    AccountAgent.add_balance(agent, account_1.account_id, 1000)
    AccountAgent.add_balance(agent, account_2.account_id, 500)

    # Make a transaction
    TransactionApp.make_transaction(account_1.account_id, account_2.account_id, 200)

    # Get the transactions
    transactions = TransactionApp.get_transactions()
    assert length(transactions) == 1
  end

  test "Making transactions should save the transactions", %{agent: agent} do

    #  Create two accounts
    account_1 = AccountAgent.create_account(agent, "Account 2", "USD")
    account_2 = AccountAgent.create_account(agent, "account 2", "USD")

    # Add balance to both accounts
    AccountAgent.add_balance(agent, account_1.account_id, 500)
    AccountAgent.add_balance(agent, account_2.account_id, 800)

    # Make a transaction
    TransactionApp.make_transaction(account_1.account_id, account_2.account_id, 200)
    # Make another transaction
    TransactionApp.make_transaction(account_1.account_id, account_2.account_id, 100)
    # Make another transaction
    TransactionApp.make_transaction(account_1.account_id, account_2.account_id, 200)

    # Get the transactions
    transactions = TransactionApp.get_transactions()
    assert length(transactions) == 3

  end
end
