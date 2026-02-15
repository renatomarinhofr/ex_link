defmodule ExLink.LinksTest do
  use ExLink.DataCase

  alias ExLink.Links

  describe "links" do
    alias ExLink.Links.Link

    import ExLink.LinksFixtures

    @invalid_attrs %{original_url: nil, short_code: nil, clicks: nil, expires_at: nil}

    test "list_links/0 returns all links" do
      link = link_fixture()
      assert Links.list_links() == [link]
    end

    test "get_link!/1 returns the link with given id" do
      link = link_fixture()
      assert Links.get_link!(link.id) == link
    end

    test "create_link/1 with valid data creates a link" do
      valid_attrs = %{original_url: "some original_url", short_code: "some short_code", clicks: 42, expires_at: ~U[2026-02-14 18:16:00Z]}

      assert {:ok, %Link{} = link} = Links.create_link(valid_attrs)
      assert link.original_url == "some original_url"
      assert link.short_code == "some short_code"
      assert link.clicks == 42
      assert link.expires_at == ~U[2026-02-14 18:16:00Z]
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Links.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      update_attrs = %{original_url: "some updated original_url", short_code: "some updated short_code", clicks: 43, expires_at: ~U[2026-02-15 18:16:00Z]}

      assert {:ok, %Link{} = link} = Links.update_link(link, update_attrs)
      assert link.original_url == "some updated original_url"
      assert link.short_code == "some updated short_code"
      assert link.clicks == 43
      assert link.expires_at == ~U[2026-02-15 18:16:00Z]
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Links.update_link(link, @invalid_attrs)
      assert link == Links.get_link!(link.id)
    end

    test "delete_link/1 deletes the link" do
      link = link_fixture()
      assert {:ok, %Link{}} = Links.delete_link(link)
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(link.id) end
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Links.change_link(link)
    end
  end
end
