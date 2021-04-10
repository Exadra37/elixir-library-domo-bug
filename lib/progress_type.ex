defmodule ProgressType do

  use Domo

  @derive Jason.Encoder

  typedstruct do
    field :state, :backlog | :todo | :doing | :pending | :done | :archived
    field :title, String.t()
    field :since, NaiveDateTime.t()
  end

  def default() do
    new!(
      state: :todo,
      title: "Task Todo",
      since: NaiveDateTime.utc_now()
    )
  end
end
