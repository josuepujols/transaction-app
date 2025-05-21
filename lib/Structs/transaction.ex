defmodule Structs.Transaction do
  defstruct transaction_id: nil,
            account_id: nil,
            destination_account_id: nil,
            amount: 0,
            timestamp: nil

  @type t() :: %__MODULE__{
          transaction_id: integer(),
          account_id: integer(),
          destination_account_id: integer(),
          amount: float(),
          timestamp: DateTime.t()
        }
end
