defmodule VbtCredo.Check.Consistency.ModuleLayoutTest do
  use Credo.TestHelper

  @described_check VbtCredo.Check.Consistency.ModuleLayout

  test "no errors are reported on a successful layout" do
    """
    defmodule Test do
      @moduledoc "some doc"

      @behaviour GenServer
      @behaviour Supervisor

      use GenServer

      import GenServer

      alias GenServer
      alias Mod1.{Mod2, Mod3}

      require GenServer

      @x 1

      defstruct x: 1, y: 2

      @type x :: pos_integer

      @callback callback() :: any

      @macrocallback macrocallback() :: any

      @optional_callbacks [callback: 0]
    end
    """
    |> to_source_file
    |> refute_issues(@described_check)
  end

  test "moduledoc must appear before behaviour" do
    [issue] =
      """
      defmodule Test do
        @behaviour GenServer
        @moduledoc "some doc"
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of module documentation."
  end

  test "behaviour must appear before use" do
    [issue] =
      """
      defmodule Test do
        use GenServer
        @behaviour GenServer
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of behaviour."
  end

  test "use must appear before import" do
    [issue] =
      """
      defmodule Test do
        import GenServer
        use GenServer
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of use."
  end

  test "import must appear before alias" do
    [issue] =
      """
      defmodule Test do
        alias GenServer
        import GenServer
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of import."
  end

  test "alias must appear before require" do
    [issue] =
      """
      defmodule Test do
        require GenServer
        alias GenServer
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of alias."
  end

  test "require must appear before module attribute" do
    [issue] =
      """
      defmodule Test do
        @x 1
        require GenServer
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of require."
  end

  test "module attribute must appear before defstruct" do
    [issue] =
      """
      defmodule Test do
        defstruct x: 1, y: 2
        @x 1
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of module attribute."
  end

  test "defstruct must appear before type" do
    [issue] =
      """
      defmodule Test do
        @type x :: pos_integer
        defstruct x: 1, y: 2
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of defstruct."
  end

  test "type must appear before callback" do
    [issue] =
      """
      defmodule Test do
        @callback callback() :: any
        @type x :: pos_integer
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of type."
  end

  test "callback must appear before macrocallback" do
    [issue] =
      """
      defmodule Test do
        @macrocallback macrocallback() :: any
        @callback callback() :: any
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of callback."
  end

  test "macrocallback must appear before optional_callbacks" do
    [issue] =
      """
      defmodule Test do
        @optional_callbacks :: [callback: 0]
        @macrocallback macrocallback() :: any
      end
      """
      |> to_source_file
      |> assert_issue(@described_check)

    assert issue.message == "Invalid placement of macrocallback."
  end
end
