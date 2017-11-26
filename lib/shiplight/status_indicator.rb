require 'blink1'

module Shiplight
  class StatusIndicator
    LED_PATTERNS = {
      'running' => [:solid, [0xff, 0xdf, 0x00]],
      'success' => [:solid, [0x00, 0xc0, 0x00]],
      'error'   => [:blink, [0xc0, 0x00, 0x00]]
    }.freeze

    DELAY = 1000

    def status=(status)
      led.open
      send(*LED_PATTERNS.fetch(status, [:off]))
      led.close
    end

    private

    def led
      @led ||= Blink1.new
    end

    def solid(color)
      led.fade_to_rgb(DELAY, *color)
    end

    def blink(color)
      clear_pattern
      led.write_pattern_line(DELAY, *color, 0)
      led.write_pattern_line(DELAY, 0, 0, 0, 1)
      led.play(0)
    end

    def off
      led.off
    end

    def clear_pattern
      32.times { |idx| led.write_pattern_line(0, 0, 0, 0, idx) }
    end
  end
end
