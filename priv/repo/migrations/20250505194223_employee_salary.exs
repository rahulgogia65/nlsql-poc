defmodule Nlsql.Repo.Migrations.EmployeeSalary do
  use Ecto.Migration

  def change do
    create table(:employee_salary) do
      add :experience, :integer
      add :age, :integer
      add :gender, :string
      add :salary, :integer
    end
  end
end
