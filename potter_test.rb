require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'minitest'
end

require 'minitest/autorun'

module Potter
  BASE_PRICE = 800

  def shop(books)
    return 0 if books.empty?

    all_groups(books)
      .map { |group| group.map { |books| price(books) }.sum(0) }
      .min
  end

  private

  def price(distinct_books)
    BASE_PRICE * case distinct_books.size
                 when 2 then 2 * 0.95 #  5% off
                 when 3 then 3 * 0.90 # 10% off
                 when 4 then 4 * 0.80 # 20% off
                 when 5 then 5 * 0.75 # 25% off
                 else distinct_books.size
                 end
  end

  def all_groups(books)
    books.reduce([[]]) do |groups, book|
      groups.map { |group| add_value(group, book) }.reduce(&:+)
    end
  end

  def add_value(group, value)
    result = [ [*group, [value]] ]
    group.each.with_index do |books, index|
      next if books.include?(value)

      result << [
        *group[0...index],
        books + [value],
        *group[(index + 1)..-1],
      ]
    end
    result
  end
end

class PotterTest < Minitest::Test
  include Potter

  def test_shopping_nothing
    assert_equal 0, shop([])
  end

  def test_shopping_one_book_costs_8_euros
    book = rand(1..5)
    assert_equal 800, shop([book])
  end

  def test_shopping_two_different_books_gives_5_percent_discount
    book1, book2 = (1..5).to_a.shuffle.take(2)
    assert_equal 1520, shop([book1, book2])
  end

  def test_shopping_multiple_times_the_same_book_gives_no_discount
    book = rand(1..5)
    assert_equal 2400, shop([book] * 3)
  end

  def test_problem_example
    # 2 copies of the first book
    # 2 copies of the second book
    # 2 copies of the third book
    # 1 copy of the fourth book
    # 1 copy of the fifth book
    assert_equal 5120, shop([1, 1, 2, 2, 3, 3, 4, 5])
  end

  def test_add_value_to_a_group_of_books
    assert_equal [[[1]]], add_value([], 1)
    assert_equal [[[1], [1]]], add_value([[1]], 1)
    assert_equal [[[1], [2]], [[1, 2]]], add_value([[1]], 2)
    assert_equal [[[1], [2], [1]], [[1], [2, 1]]], add_value([[1], [2]], 1)
    assert_equal [[[1], [2], [3]], [[1, 3], [2]], [[1], [2, 3]]], add_value([[1], [2]], 3)
  end

  def test_grouping_books_together
    assert_equal [[]], all_groups([])

    assert_equal [[[1]]], all_groups([1])

    assert_equal [
      [[1], [2]],
      [[1, 2]],
    ], all_groups([1, 2])

    assert_equal [
      [[1], [2], [3]],
      [[1, 3], [2]],
      [[1], [2, 3]],
      [[1, 2], [3]],
      [[1, 2, 3]],
    ], all_groups([1, 2, 3])

    assert_equal [
      [[1], [1], [2]],
      [[1, 2], [1]],
      [[1], [1, 2]],
    ], all_groups([1, 1, 2])
  end
end
