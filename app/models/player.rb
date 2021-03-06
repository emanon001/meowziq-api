class Player
  def run
    @player_pid = nil
    @play_next = true
    @player = nil
    @watcher = nil

    run_watcher
    @watcher.join
  end

  private

  def play
    return if @player_pid
    @play_next = true
    @player_pid = nil
    @player = Thread.new do
      while @play_next
        sleep 1

        # get current song
        songs = Song.where(deleted_at: nil).order(id: :asc)
        current_song = songs.first
        next unless current_song
        current_song.deleted_at = Time.zone.now
        current_song.save!

        # play
        if File.exists? current_song.path
          @player_pid = spawn "mplayer #{current_song.path}"
          player = Process.detach @player_pid
          player.join
        end
      end
    end
  end

  def run_watcher
    @watcher = Thread.new do
      current_status = nil
      while true
        status = Status.first
        case status.text
        when 'play' then
          current_status = 'play'
          play
        when 'stop' then
          current_status = 'stop'
          stop
        when 'skip' then
          current_status = 'skip'
          skip
          current_status = 'play' # to ignore the following update
          status.text = 'play'
          status.save!
        else
          p "unknown status #{status.text}"
        end unless status.text == current_status
        sleep 1
      end
    end
  end

  def skip
    return unless @player_pid
    @play_next = true
    Process.kill :TERM, @player_pid
    @player_pid = nil
  end

  def stop
    return unless @player_pid
    @play_next = false
    Process.kill :TERM, @player_pid
    @player_pid = nil
  end
end
