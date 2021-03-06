defmodule Portal do
  @moduledoc """
  Create a Portal with two colored doors for transferring data.
  """

  alias Portal.Door

  @doc """
  The `left` and `right` doors of the Portal.
  """
  defstruct [:left, :right]

  @doc """
  Create a new Portal door with given `color` in the supervisor.

  Returns `{:ok, pid}` where `pid` is the PID of the created process.
  """
  @spec create(:atom) :: {:ok, pid}
  def create(color) do
    Supervisor.start_child(Portal.Supervisor, [color])
  end

  @doc """
  Setup transfer of `data` between `left` and `right` doors.

  Returns a Portal struct: `%Portal{left: left, right: right}`
  """
  @spec setup(pid, pid, list) :: struct
  def setup(left, right, data) do
    # Add all data to the portal on the left.
    for item <- data do
      Door.push(left, item)
    end

    %Portal{left: left, right: right}
  end

  @doc """
  Pushes data in one direction (to the `:left` or `:right`) for the given `portal`.

  Returns a pretty-printed Portal struct showing the current status of the Portals.
  E.g.
      :orange <=> :blue
    [1, 2, 3] <=> []
 
  Raises an ArgumentError if an invalid `direction` is used.
  """
  def push_data(portal, direction) do
    case direction do
      :left   -> push(portal.right, portal.left)
      :right  -> push(portal.left, portal.right)
      _       -> raise ArgumentError, message: "Invalid direction: #{direction}"
    end

    # Return the portal so our protocol displays it properly.
    portal
  end

  @doc false
  @spec push(pid, pid) :: :ok
  defp push(from, to) do
    # If possible, pushes data from the `from` door to the `to` door.
    # Otherwise, do nothing.
    case Door.pop(from) do
      :error        -> :ok
      {:ok, value}  -> Door.push(to, value)
    end
  end
end

defimpl Inspect, for: Portal do
  @doc """
  Display the Portal data in a more readable way.

  E.g.
      :orange <=> :blue
    [1, 2, 3] <=> []
  """
  def inspect(%Portal{left: left, right: right}, _) do
    left_door  = inspect(left)
    right_door = inspect(right)

    left_data  = inspect(Enum.reverse(Portal.Door.get(left)))
    right_data = inspect(Portal.Door.get(right))

    max = max(String.length(left_door), String.length(left_data))

    # Use String.rjust() to make sure the columns line up.
    """

      #{String.rjust(left_door, max)} <=> #{right_door}
      #{String.rjust(left_data, max)} <=> #{right_data}
    """
  end
end
