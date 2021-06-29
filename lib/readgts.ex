defmodule Readgts do

  # GTSデータをJSON形式に変換
  def read_gts do
    # 1. リストを要素に持つリストに変換
    [top | data] =
    File.read!("cube.gts.txt")
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&Enum.reject(&1, fn x -> x == "" end))
    |> Enum.map(& if Enum.empty?(&1) == false do &1 end)
    |> Enum.filter(& &1)

    # 2. 個数を表す1行目 = top, 以降各データ = data に分解
    # top = [8, 18, 12] = [頂点の数, 線分の数, 三角形の数]
    top =
    Enum.map(top, &String.to_integer(&1))

    # data = 頂点の x,y,z *8
    #        線分の startpoint,endpoint *18
    #        三角形の first,second,third *12
    data =
    Enum.map(data, &Enum.map(&1, fn x -> x <> ".0" end))
    |> Enum.map(&Enum.map(&1, fn x -> String.to_float(x) end))
    # |> Enum.map(&Enum.map(&1, fn x -> Kernel.trunc(x) end))

    # 3. 頂点、線分、三角形の各値にキーを設定
    # 頂点
    vertex =
    Enum.take(data, Enum.at(top, 0))
    |> Enum.map(&Enum.zip([:x, :y, :z], &1))

    # 線分
    line =
    Enum.drop(data, Enum.at(top, 0))
    |> Enum.take(Enum.at(top, 1))
    |> Enum.map(&Enum.zip([:startpoint, :endpoint], &1))

    # 三角形
    triangle =
    Enum.drop(data, Enum.at(top, 0) + Enum.at(top, 1))
    |> Enum.take(Enum.at(top, 2))
    |> Enum.map(&Enum.zip([:first, :second, :third],&1))

    # 4. 3を合体させ、1つのデータとしてJSON形式に変換
    change_json =
    vertex ++ line ++ triangle
    |> Enum.map(&Enum.into(&1, %{}))
    |> Poison.encode!
  end

  # JSONファイル書き出し
  def write_json do
    File.write("cube.json", read_gts())
  end
end
