defmodule SpaceTank do
  @type action :: :land | :launch

  @type error_type ::
          :negative_mass
          | :negative_gravity
          | :not_supported_action

  @type error :: {:error, error_type()}

  @spec fuel_for_launch(integer(), float()) :: integer()
  defp fuel_for_launch(mass, gravity), do: trunc(mass * gravity * 0.042 - 33)

  @spec fuel_for_land(integer(), float()) :: integer()
  defp fuel_for_land(mass, gravity), do: trunc(mass * gravity * 0.033 - 42)

  @spec calc_fuel(integer(), float(), (integer(), float() -> integer()), integer()) ::
          integer()
  defp calc_fuel(mass, gravity, fuel_calc_fn, fuel) do
    new_fuel = fuel_calc_fn.(mass, gravity)

    if new_fuel <= 0 do
      fuel
    else
      calc_fuel(new_fuel, gravity, fuel_calc_fn, fuel + new_fuel)
    end
  end

  @spec validate_mass(any) :: :ok | error()
  defp validate_mass(mass) do
    if mass <= 0 do
      {:error, :negative_mass}
    else
      :ok
    end
  end

  @spec validate_gravity(float()) :: :ok | error()
  defp validate_gravity(gravity) do
    if gravity <= 0 do
      {:error, :negative_gravity}
    else
      :ok
    end
  end

  @spec get_action(action()) :: {:ok, fun(2)} | error()
  defp get_action(action) do
    case action do
      :launch -> {:ok, &fuel_for_launch/2}
      :land -> {:ok, &fuel_for_land/2}
      _ -> {:error, :not_supported_action}
    end
  end

  @spec calc_fuel(integer(), float(), action()) :: {:ok, integer()} | error()
  def calc_fuel(mass, gravity, action) do
    with :ok <- validate_mass(mass),
         :ok <- validate_gravity(gravity),
         {:ok, fuel_calc_fn} <- get_action(action) do
      {:ok, calc_fuel(mass, gravity, fuel_calc_fn, 0)}
    end
  end

  @spec calc_fuel_for_paths(integer(), [{action, float()}]) :: {:ok, integer()} | error()
  def calc_fuel_for_paths(mass, paths) do
    paths
    |> Enum.reverse()
    |> Enum.reduce({:ok, 0}, fn {action, gravity}, fuel_result ->
      with {:ok, fuel} <- fuel_result,
           {:ok, new_fuel} <- calc_fuel(mass + fuel, gravity, action) do
        {:ok, new_fuel + fuel}
      end
    end)
  end
end
