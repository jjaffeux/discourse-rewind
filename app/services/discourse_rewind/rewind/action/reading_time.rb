# frozen_string_literal: true

# For showcasing the reading time of a user
# Should we show book covers or just the names?
module DiscourseRewind
  class Rewind::Action::PostingCalendar < Service::ActionBase
    option :params
    option :guardian

    delegate :username, :year, to: :params, private: true

    def call
      user = User.find_by_username(username)

      reading_time =
        UserVisit.where(user: user).where(visited_at: Date.new(year).all_year).sum(:time_read)

      {
        data: {
          reading_time: reading_time,
          books: best_book_fit(reading_time),
        },
        identifier: "posting-calendar",
      }
    end

    def popular_book_reading_time
      {
        "The Hunger Games" => 19_740,
        "The Metamorphosis" => 3120,
        "To Kill a Mockingbird" => 22_800,
        "Pride and Prejudice" => 25_200,
        "1984" => 16_800,
        "The Lord of the Rings" => 108_000,
        "Harry Potter and the Sorcerer's Stone" => 24_600,
        "The Great Gatsby" => 12_600,
        "The Little Prince" => 5400,
        "Animal Farm" => 7200,
        "The Catcher in the Rye" => 18_000,
        "Jane Eyre" => 34_200,
        "Fahrenheit 451" => 15_000,
        "The Hobbit" => 27_000,
        "The Da Vinci Code" => 37_800,
        "Little Women" => 30_000,
        "One Hundred Years of Solitude" => 46_800,
        "And Then There Were None" => 16_200,
        "The Alchemist" => 10_800,
        "The Hitchhiker's Guide to the Galaxy" => 12_600,
      }
    end

    def best_book_fit(reading_time)
      reading_time_rest = reading_time
      books = []
      while reading_time_rest > 0
        books << popular_book_reading_time.min_by { |_, v| (v - reading_time_rest).abs }.first
        reading_time_rest -= popular_book_reading_time[books.last]
      end
      books.group_by(&:itself).transform_values(&:count)
    end
  end
end
