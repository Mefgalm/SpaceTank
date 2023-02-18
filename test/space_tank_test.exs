defmodule SpaceTankTest do
  use ExUnit.Case
  doctest SpaceTank

  test "empty paths" do
    res = SpaceTank.calc_fuel_for_paths(10, [])
    assert res == {:ok, 0}
  end

  test "negative mass" do
    res = SpaceTank.calc_fuel_for_paths(-10, [{:launch, 9}])

    assert res == {:error, :negative_mass}
  end

  test "wrong action" do
    res = SpaceTank.calc_fuel_for_paths(10, [{:do, 9}])

    assert res == {:error, :not_supported_action}
  end

  test "negative gravity" do
    res = SpaceTank.calc_fuel_for_paths(10, [{:launch, -9}])

    assert res == {:error, :negative_gravity}
  end

  test "case 1" do
    res =
      SpaceTank.calc_fuel_for_paths(28801,
        launch: 9.807,
        land: 1.62,
        launch: 1.62,
        land: 9.807
      )

    assert res == {:ok, 51898}
  end

  test "case 2" do
    res =
      SpaceTank.calc_fuel_for_paths(14606, [
        {:launch, 9.807},
        {:land, 3.711},
        {:launch, 3.711},
        {:land, 9.807}
      ])

    assert res == {:ok, 33388}
  end

  test "case 3" do
    res =
      SpaceTank.calc_fuel_for_paths(75432, [
        {:launch, 9.807},
        {:land, 1.62},
        {:launch, 1.62},
        {:land, 3.711},
        {:launch, 3.711},
        {:land, 9.807}
      ])

    assert res == {:ok, 212_161}
  end
end
