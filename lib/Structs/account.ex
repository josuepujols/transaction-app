defmodule Structs.Account do
  defstruct account_id: nil,
            name: nil,
            balance: 0,
            currency: nil

  @type t() :: %__MODULE__{
          account_id: integer(),
          name: String.t(),
          balance: float(),
          currency: String.t()
        }
end
