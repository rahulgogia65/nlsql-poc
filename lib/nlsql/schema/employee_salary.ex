defmodule Nlsql.Schema.EmployeeSalary do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employee_salary" do
    field :experience, :integer
    field :age, :integer
    field :salary, :float
    field :gender, :string
  end

  def changeset(employee_salary, attrs) do
    employee_salary
    |> cast(attrs, [:experience, :age, :salary, :gender])
    |> validate_required([:experience, :age, :salary, :gender])
  end
end
