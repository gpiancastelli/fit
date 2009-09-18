require 'fit/fixture'

module Eg
  module Book

    class ChatServerActions < Fit::Fixture
      def initialize
        @chat = ChatRoom.new
      end
      def user user_name
        @user_name = user_name
      end
      def connect
        @chat.connect_user @user_name
      end
      def room room_name
        @room_name = room_name
      end
      def new_room
        @chat.user_creates_room @user_name, @room_name
      end
      def enter_room
        @chat.user_enters_room @user_name, @room_name
      end
      def occupant_count
        @chat.occupants @room_name
      end
    end

    class ChatRoom
      def initialize
        @users = {}
        @rooms = {}
      end
      def connect_user user_name
        return false unless @users[user_name].nil?
        @users[user_name] = User.new user_name
        return true
      end
      def user_creates_room user_name, room_name
        user = @users[user_name]
        raise Exception.new("Unknown user name: #{user_name}") unless user
        raise Exception.new("Duplicate room name: #{room_name}") if @rooms.include? room_name
        @rooms[room_name] = Room.new room_name, user, self
      end
      def user_enters_room user_name, room_name
        user = @users[user_name]
        room = @rooms[room_name]
        return false if user.nil? or room.nil?
        room.add user
        return true
      end
      def occupants room_name
        room = @rooms[room_name]
        raise Exception.new("Unknown room: #{room_name}") unless room
        room.occupant_count
      end
    end

    class User
      attr_accessor :name
      def initialize name
        @name = name
      end
    end

    require 'set'

    class Room
      def initialize room_name, owner, chat
        @name = room_name
        @owner = owner
        @chat = chat
        @users = Set.new
      end
      def add user
        @users.add user
      end
      def occupant_count
        @users.size
      end
    end

  end
end
