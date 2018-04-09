Settings = [
  {
    name: 'input_mode',
    type: :enum,
    max: 'JRK_INPUT_MODE_PULSE_WIDTH',
    default: 'JRK_INPUT_MODE_SERIAL',
    default_is_zero: true,
    english_default: 'serial',
    comment: <<EOF
The input mode setting specifies how you want to control the jrk.  It
determines the definition of the input and target variables.  The input
variable is raw measurement of the jrk's input.  The target variable is the
desired state of the system's output, and feeds into the PID feedback
algorithm.

- If the input mode is "Serial" (JRK_INPUT_MODE_SERIAL), the jrk gets it
  input and target settings over its USB, serial, or I2C interfaces.  You
  would send Set Target commands to the jrk to set both the input and target
  variables.

- If the input mode is "Analog voltage" (JRK_INPUT_MODE_ANALOG), the jrk gets
  it input variable by reading the voltage on its SDA/AN pin.  A signal level
  of 0 V corresponds to an input value of 0, and a signal elvel of 5 V
  corresponds to an input value of 4092.  The jrk uses its input scaling
  feature to set the target variable.

- If the input mode is "Pulse width" (JRK_INPUT_MODE_PULSE_WIDTH), the jrk
  gets it input variable by reading RC pulses on its RC pin.  The input value
  is the width of the most recent pulse, in units of 2/3 microseconds.  The
  jrk uses its input scaling feature to set the target variable.
EOF
  },
  {
    name: 'input_error_minimum',
    type: :uint16_t,
    range: 0..4095,
    comment: <<EOF
If the raw input value is below this value, it causes an "Input disconnect"
error.
EOF
  },
  {
    name: 'input_error_maximum',
    type: :uint16_t,
    range: 0..4095,
    default: 4095,
    comment: <<EOF
If the raw input value is above this value, it causes an "Input disconnect"
error.
EOF
  },
  {
    name: 'input_minimum',
    type: :uint16_t,
    range: 0..4095,
    comment: <<EOF
This is one of the parameters of the input scaling feature, which is how the
jrk calculates its target value from its raw input.

By default, the input scaling:

1. Maps all values less than the input_minimum to the output_minimum.
2. Maps all values greater than the input_maximum to the output_maximum.
3. Maps all values between the input_neutral_min and input_neutral_max to
   the output the output_neutral.
4. Behaves linearly between those regions.

The input_invert parameter can flip that correspondence, and the
input_scaling_degree parameter can change item 4 to use higher-order curves
that give you finer control of the output near the neutral region.
EOF
  },
  {
    name: 'input_maximum',
    type: :uint16_t,
    range: 0..4095,
    default: 4095,
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'input_neutral_minimum',
    type: :uint16_t,
    range: 0..4095,
    default: 2048,
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'input_neutral_maximum',
    type: :uint16_t,
    range: 0..4095,
    default: 2048,
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'output_minimum',
    type: :uint16_t,
    range: 0..4095,
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'output_neutral',
    type: :uint16_t,
    range: 0..4095,
    default: 2048,
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'output_maximum',
    type: :uint16_t,
    range: 0..4095,
    default: 4095,
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'input_invert',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE2',
    bit_address: 'JRK_OPTIONS_BYTE2_INPUT_INVERT',
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'input_scaling_degree',
    type: :enum,
    default: 'JRK_SCALING_DEGREE_LINEAR',
    default_is_zero: true,
    english_default: 'linear',
    max: 'JRK_SCALING_DEGREE_QUINTIC',
    comment:
      "This is one of the parameters of the input scaling, as described in the\n" \
      "input_minimum documentation."
  },
  {
    name: 'input_detect_disconnect',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE2',
    bit_address: 'JRK_OPTIONS_BYTE2_INPUT_DETECT_DISCONNECT',
    comment:
      "If the input mode is JRK_INPUT_MODE_ANALOG, this setting causes the jrk to\n" \
      "drive its designated potentiometer power pins (SCL and/or AUX) low once per\n" \
      "PID period and make sure that the input potentiometer reading on the SDA/AN\n" \
      "pin also goes low.  If it does not go low, the jrk signals an input\n" \
      "disconnect error.\n\n" \
      "If you enable this setting, we recommend powering your potentiometer from\n" \
      "GND and SCL."
  },
  {
    name: 'input_analog_samples_exponent',
    type: :uint8_t,
    range: 0..10,
    default: 7,
    comment:
      "This setting specifies how many analog samples to take if the input mode\n" \
      "is analog.  The number of samples will be 2^x, where x is this setting.",
  },
  {
    name: 'feedback_mode',
    type: :enum,
    default: 'JRK_FEEDBACK_MODE_ANALOG',
    english_default: 'analog',
    max: 'JRK_FEEDBACK_MODE_FREQUENCY',
    comment: <<EOF
The feedback mode setting specifies whether the jrk is using feedback from
the output of the system, and if so defines what interface is used to
measure that feedback.

- If the feedback mode is "None" (JRK_FEEDBACK_MODE_NONE), feedback and PID
  calculations are disabled.  The duty cycle target variable is always equal
  to the target variable minus 2048, instead of being the result of a PID
  calculation.  This means that a target of 2648 corresponds to driving the
  motor full speed forward, 2048 is brake, and 1448 is full-speed reverse.

- If the feedback mode is "Analog" (JRK_FEEDBACK_MODE_ANALOG), the jrk gets
  its feedback by measuring the voltage on the FBA pin.  A level of 0 V
  corresponds to a feedback value of 0, and a level of 5 V corresponds to a
  feedback value of 4092.  The feedback scaling algorithm computes the scaled
  feedback variable, and the PID algorithm uses the scaled feedback and the
  target to compute the duty cycle target.

- If the feedback mode is "Frequency (digital)"
  (JRK_FEEDBACK_MODE_FREQUENCY), the jrk gets it feedback by counting rising
  edges on its FBT pin.  When the target is greater than 2048, the feedback
  value is 2048 plus the number of rising edges detected during the PID
  period.  Otherwise, the the feedback is 2048 minus the the number of rising
  edges detected during the PID period.
EOF
  },
  {
    name: 'feedback_error_minimum',
    type: :uint16_t,
    range: 0..4095,
    comment: <<EOF
If the raw feedback value is below this value, it causes a
"Feedback disconnect" error.
EOF
  },
  {
    name: 'feedback_error_maximum',
    type: :uint16_t,
    range: 0..4095,
    default: 4095,
    comment: <<EOF
If the raw feedback value is below this value, it causes a
"Feedback disconnect" error.
EOF
  },
  {
    name: 'feedback_minimum',
    type: :uint16_t,
    range: 0..4095,
    comment:
      "This is one of the parameters of the feedback scaling feature.\n\n" \
      "By default, the feedback scaling:\n\n" \
      "  1. Maps values less than or equal to feedback_minimum to 0.\n" \
      "  2. Maps values less than or equal to feedback_maximum to 4095.\n" \
      "  3. Behaves linearly between those two regions.\n\n" \
      "The feedback_invert parameter causes the mapping to be flipped.\n"
  },
  {
    name: 'feedback_maximum',
    type: :uint16_t,
    range: 0..4095,
    default: 4095,
    comment:
      "This is one of the parameters of the feedback scaling described in\n" \
      "the feedback_minimum documentation."
  },
  {
    name: 'feedback_invert',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE2',
    bit_address: 'JRK_OPTIONS_BYTE2_FEEDBACK_INVERT',
    comment:
      "This is one of the parameters of the feedback scaling described in\n" \
      "the feedback_minimum documentation."
  },
  {
    name: 'feedback_detect_disconnect',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE2',
    bit_address: 'JRK_OPTIONS_BYTE2_FEEDBACK_DETECT_DISCONNECT',
    comment:
      "If the feedback mode is JRK_FEEDBACK_MODE_ANALOG, this setting causes the jrk\n" \
      "to drive its designated potentiometer power pins (SCL and/or AUX) low once\n" \
      "per PID period and make sure that the feedback potentiometer reading on FBA\n" \
      "also goes low.  If it does not go low, the jrk signals a feedback\n" \
      "disconnect error.\n\n" \
      "If you enable this setting, we recommend powering your potentiometer from\n" \
      "GND and AUX."
  },
  {
    name: 'feedback_dead_zone',
    type: :uint8_t,
    comment: <<EOF
The jrk sets the duty cycle target to zero and resets the integral
whenever the magnitude of the error is smaller than this setting. This is
useful for preventing the motor from driving when the target is very close to
scaled feedback.

The jrk uses hysteresis to keep the system from simply riding the edge of the
feedback dead zone; once in the dead zone, the duty cycle and integral will
remain zero until the magnitude of the error exceeds twice the value of the
dead zone.
EOF
  },
  {
    name: 'feedback_analog_samples_exponent',
    type: :uint8_t,
    range: 0..10,
    default: 7,
    comment:
      "This setting specifies how many analog samples to take if the feedback mode\n" \
      "is analog.  The number of samples will be 2^x, where x is this setting.",
  },
  {
    name: 'feedback_wraparound',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE2',
    bit_address: 'JRK_OPTIONS_BYTE2_FEEDBACK_WRAPAROUND',
    comment:
      "Normally, the error variable used by the PID algorithm is simply the scaled\n" \
      "feedback minus the target.  With this setting enabled, the PID algorithm\n" \
      "will add or subtract 4096 from that error value to get it into the -2048 to\n" \
      "2048 range.  This is useful for systems where the output of the system wraps\n" \
      "around, so that 0 is next to 4095.  The jrk will know how to take the\n" \
      "shortest path from one point to another even if it involves wrapping around\n" \
      "from 0 to 4095 or vice versa.",
  },
  {
    name: 'serial_mode',
    type: :enum,
    default: 'JRK_SERIAL_MODE_USB_DUAL_PORT',
    default_is_zero: true,
    english_default: 'USB dual port',
    max: 'JRK_SERIAL_MODE_UART',
    comment: <<EOF
The serial mode determines how bytes are transferred between the jrk's UART
(TX and RX pins), its two USB virtual serial ports (the command port and the
TTL Port), and its serial command processor.

- If the serial mode is "USB dual port" (JRK_SERIAL_MODE_USB_DUAL_PORT), the
  command port can be used to send commands to the jrk and receive responses
  from it, while the TTL port can be used to send and receives bytes on the
  TX and RX lines.  The baud rate you set by the USB host on the TTL port
  determines the baud rate used on the TX and RX lines.

- If the serial mode is "USB chained" (JRK_SERIAL_MODE_USB_CHAINED), the
  comamnd port can be used to both transmit bytes on the TX line and send
  commands to the jrk.  The jrk's responses to those commands will be sent to
  the command port but not the TX line.  If the input mode is serial, bytes
  received on the RX line will be sent to the command put but will not be
  interpreted as command bytes by the jrk.  The baud rate set by the USB host
  on the command port determines the baud rate used on the TX and RX lines.

- If the serial mode is "UART" (JRK_SERIAL_MODE_UART), the TX and RX lines
  can be used to send commands to the jrk and receive responses from it.  Any
  byte received on RX will be sent to the command port, but bytes sent from
  the command port will be ignored.
EOF
  },
  {
    name: 'serial_baud_rate',
    type: :uint32_t,
    custom_fix: true,
    custom_eeprom: true,
    comment:
      "This setting specifies the baud rate to use on the RX and TX pins\n" \
      "when the serial mode is UART.  It should be between\n" \
      "JRK_MIN_ALLOWED_BAUD_RATE and JRK_MAX_ALLOWED_BAUD_RATE.",
  },
  {
    name: 'serial_timeout',
    type: :uint32_t,
    custom_eeprom: true,
    custom_fix: true,
    comment: <<EOF
This is the time in milliseconds before the device considers it to be an
error if it has not received certain commands.  A value of 0 disables the
command timeout feature.

This setting should be a multiple of 10 (JRK_SERIAL_TIMEOUT_UNITS) and be
between 0 and 655350 (JRK_MAX_ALLOWED_SERIAL_TIMEOUT).
EOF
  },
  {
    name: 'serial_device_number',
    type: :uint16_t,
    max: 16383,
    default: 11,
    custom_fix: true,
    comment: <<EOF
This is the serial device number used in the Pololu protocol on the jrk's
serial interfaces, and the I2C device address used on the jrk's I2C
interface.

By default, the jrk only pays attention to the lower 7 bits of this setting,
but if you enable 14-bit serial device numbers (see
serial_enable_14bit_device_number) then it will use the lower 14 bits.

To avoid user confusion about the ignored bits, the jrk_settings_fix()
function clears those bits and warns the user.
EOF
  },
  {
    name: 'never_sleep',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_NEVER_SLEEP',
    comment: <<EOF
By default, if the jrk is powered from a USB bus that is in suspend mode
(e.g. the computer is sleeping) and VIN power is not present, it will go to
sleep to reduce its current consumption and comply with the USB
specification.  If you enable the "Never sleep" option, the jrk will never go
to sleep.
EOF
  },
  {
    name: 'serial_enable_crc',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_SERIAL_ENABLE_CRC',
    comment: <<EOF
If set to true, the jrk requires a 7-bit CRC byte at the end of each serial
command, and if the CRC byte is wrong then it ignores the command and sets
the serial CRC error bit.
EOF
  },
  {
    name: 'serial_enable_14bit_device_number',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_SERIAL_ENABLE_14BIT_DEVICE_NUMBER',
    comment: <<EOF
If enabled, the jrk's Pololu protocol will require a 14-bit device number to
be sent with every command.  This option allows you to put more than 128 jrk
devices on one serial bus.
EOF
  },
  {
    name: 'serial_disable_compact_protocol',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_SERIAL_DISABLE_COMPACT_PROTOCOL',
    comment: <<EOF
If enabled, the jrk will not respond to compact protocol commands.
EOF
  },
  {
    name: 'proportional_multiplier',
    type: :uint16_t,
    overridable: true,
    max: 1023,
    comment:
      "The allowed range of this setting is 0 to 1023.\n\n" \
      "In the PID algorithm, the error (the difference between scaled feedback\n" \
      "and target) is multiplied by a number called the proportional coefficient to\n" \
      "determine its effect on the motor duty cycle.\n\n" \
      "The proportional coefficient is defined by this mathematical expression:\n" \
      "  proportional_multiplier / 2^(proportional_exponent)\n"
  },
  {
    name: 'proportional_exponent',
    type: :uint8_t,
    overridable: true,
    max: 18,
    comment:
      "The allowed range of this setting is 0 to 18.\n" \
      "For more information, see the proportional_multiplier documentation."
  },
  {
    name: 'integral_multiplier',
    type: :uint16_t,
    overridable: true,
    max: 1023,
    comment:
      "The allowed range of this setting is 0 to 1023.\n\n" \
      "In the PID algorithm, the accumulated error (known as error sum)\n" \
      "is multiplied by a number called the integral coefficient to\n" \
      "determine its effect on the motor duty cycle.\n\n" \
      "The integral coefficient is defined by this mathematical expression:\n" \
      "  integral_multiplier / 2^(integral_exponent)\n\n" \
      "Note: On the original jrks (jrk 12v12 and jrk 21v3), the formula was\n" \
      "different.  Those jrks added 3 to the integral_exponent before using\n" \
      "it as a power of 2."
  },
  {
    name: 'integral_exponent',
    type: :uint8_t,
    overridable: true,
    max: 18,
    comment:
      "The allowed range of this setting is 0 to 18.\n" \
      "For more information, see the integral_multiplier documentation."
  },
  {
    name: 'derivative_multiplier',
    type: :uint16_t,
    overridable: true,
    max: 1023,
    comment:
      "The allowed range of this setting is 0 to 1023.\n\n" \
      "In the PID algorithm, the change in the error since the last PID period\n" \
      "is multiplied by a number called the derivative coefficient to\n" \
      "determine its effect on the motor duty cycle.\n\n" \
      "The derivative coefficient is defined by this mathematical expression:\n" \
      "  derivative_multiplier / 2^(derivative_exponent)\n"
  },
  {
    name: 'derivative_exponent',
    type: :uint8_t,
    overridable: true,
    max: 18,
    comment:
      "The allowed range of this setting is 0 to 18.\n" \
      "For more information, see the derivative_multiplier documentation.",
  },
  {
    name: 'pid_period',
    type: :uint16_t,
    overridable: true,
    range: 1..8191,
    default: 10,
    comment: <<EOF
The PID period specifies how often the jrk should calculate its input and
feedback, run its PID calculation, and update the motor speed, in units of
milliseconds.  This period is still used even if feedback and PID are
disabled.
EOF
  },
  {
    name: 'integral_reduction_exponent',
    type: :uint8_t,
    range: 0..15,
    default: 0,
    comment: <<EOF
Causes the integral variable to accumulate more slowly.
EOF
  },
  {
    name: 'integral_limit',
    type: :uint16_t,
    overridable: true,
    default: 1000,
    max: 0x7FFF,
    comment:
      "The PID algorithm prevents the absolute value of the accumulated error\n" \
      "(known as error sum) from exceeding this limit.",
  },
  {
    name: 'reset_integral',
    type: :bool,
    overridable: true,
    address: 'JRK_SETTING_OPTIONS_BYTE3',
    bit_address: 'JRK_OPTIONS_BYTE3_RESET_INTEGRAL',
    comment:
      "If this setting is set to true, the PID algorithm will reset the accumulated\n" \
      "error (also known as error sum) whenever the absolute value of the\n" \
      "proportional term (see proportional_multiplier) exceeds 600."
  },
  {
    name: 'pwm_frequency',
    type: :enum,
    default: 'JRK_PWM_FREQUENCY_20',
    default_is_zero: true,
    english_default: '20 kHz',
    max: 'JRK_PWM_FREQUENCY_5',
    comment:
      "This setting specifies whether to use 20 kHz (the default) or 5 kHz for the\n" \
      "motor PWM signal.  This setting should be either\n" \
      "JRK_PWM_FREQUENCY_20 or JRK_PWM_FREQUENCY_5.\n"
  },
  {
    name: 'current_samples_exponent',
    type: :uint8_t,
    range: 0..10,
    default: 7,
    comment:
      "This setting specifies how many analog samples to take when measuring\n" \
      "the current.  The number of samples will be 2^x, where x is this setting.",
  },
  {
    name: 'overcurrent_threshold',
    type: :uint8_t,
    default: 1,
    min: 1,
    comment: <<EOF
This is the number of consecutive PID periods where the the hardware current
chopping must occur before the jrk triggers a "Max. current exceeded\" error.
The default of 1 means that any current chopping is an error.  You can set it
to a higher value if you expect some current chopping to happen (e.g. when
starting up) but you still want to it to be an error when your motor leads
are shorted out.
EOF
  },
  {
    name: 'current_offset_calibration',
    type: :int16_t,
    default: 0,
    min: -800,
    max: 800,
    comment: <<EOF
You can use this current calibration setting to correct current measurements
and current limit settings that are off by a constant amount.

The current sense circuitry on a umc04a/umc05a jrks produces a constant
voltage of about 50 mV when the motor driver is powered, even if there is no
current flowing through the motor.  This offset must be subtracted from
analog voltages representing current limits or current measurements in order
to convert those values to amps.

For the umc04a/umc05a jrk models, this setting is defined by the formula:

  current_offset_calibration = (voltage offset in millivolts - 50) * 16

This setting should be between -800 (for an offset of 0 mV) and 800 (for an
offset of 100 mV).
EOF
  },
  {
    name: 'current_scale_calibration',
    type: :int16_t,
    default: 0,
    min: -1875,
    max: 1875,
    comment: <<EOF
You can use this current calibration setting to correct current measurements
and current limit settings that are off by a constant percentage.

The algorithm for calculating currents in amps involves multiplying the
current by (1875 + current_scale_calibration).

The default current_scale_calibration value is 0.
A current_scale_calibration value of 19 would increase the current
readings by about 1%.
EOF
  },
  {
    name: 'motor_invert',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE2',
    bit_address: 'JRK_OPTIONS_BYTE2_MOTOR_INVERT',
    comment:
      "By default, a positive duty cycle (which we call \"forward\") corresponds\n" \
      "to current flowing from output A to output B.  If enabled, this setting flips\n" \
      "the correspondence, so a positive duty cycle corresponds to current flowing\n" \
      "from B to A."
  },
  {
    name: 'max_duty_cycle_while_feedback_out_of_range',
    type: :uint16_t,
    overridable: true,
    range: 1..600,
    default: 600,
    comment: <<EOF
If the feedback is beyond the range specified by the feedback error
minimum and feedback error maximum values, then the duty cycle's magnitude
cannot exceed this value.
EOF
  },
  {
    name: 'max_acceleration_forward',
    type: :uint16_t,
    overridable: true,
    range: 1..600,
    default: 600,
    comment: <<EOF
This is the maximum allowed acceleration in the forward direction.

This is the maximum amount that the duty cycle can increase during each PID
period if the duty cycle is positive.
EOF
  },
  {
    name: 'max_acceleration_reverse',
    type: :uint16_t,
    overridable: true,
    range: 1..600,
    default: 600,
    comment: <<EOF
This is the maximum allowed acceleration in the reverse direction.

This is the maximum amount that the duty cycle can decrease during each PID
period if the duty cycle is negative.
EOF
  },
  {
    name: 'max_deceleration_forward',
    type: :uint16_t,
    overridable: true,
    range: 1..600,
    default: 600,
    comment: <<EOF
This is the maximum allowed deceleration in the forward direction.

This is the maximum amount that the duty cycle can decrease during each PID
period if the duty cycle is positive.
EOF
  },
  {
    name: 'max_deceleration_reverse',
    type: :uint16_t,
    overridable: true,
    range: 1..600,
    default: 600,
    comment: <<EOF
This is the maximum allowed deceleration in the reverse direction.

This is the maximum amount that the duty cycle can increase during each PID
period if the duty cycle is negative.
EOF
  },
  {
    name: 'max_duty_cycle_forward',
    type: :uint16_t,
    overridable: true,
    max: 600,
    default: 600,
    comment: <<EOF
This is the maximum allowed duty cycle in the forward direction.

Positive duty cycles cannot exceed this number.

A value of 600 means 100%.
EOF
  },
  {
    name: 'max_duty_cycle_reverse',
    type: :uint16_t,
    overridable: true,
    max: 600,
    default: 600,
    comment: <<EOF
This is the maximum allowed duty cycle in the reverse direction.

Negative duty cycles cannot go below this number negated.

A value of 600 means 100%.
EOF
  },
  {
    name: 'current_limit_code_forward',
    type: :uint16_t,
    overridable: true,
    default: 26,
    max: 95,
    comment: <<EOF
Sets the current limit to be used when driving forward.

This setting is not actually a current, it is a code telling the jrk how to
set up its current limiting hardware.

The correspondence between this setting and the actual current limit
in milliamps depends on what product you are using.  See also:

- jrk_current_limit_code_to_ma()
- jrk_current_limit_ma_to_code()
- jrk_current_limit_code_step()
EOF
  },
  {
    name: 'current_limit_code_reverse',
    type: :uint16_t,
    overridable: true,
    default: 26,
    max: 95,
    comment:
      "Sets the current limit to be used when driving in reverse.\n" \
      "See the documentation of current_limit_code_forward."
  },
  {
    name: 'brake_duration_forward',
    type: :uint32_t,
    overridable: true,
    max: 'JRK_MAX_ALLOWED_BRAKE_DURATION',
    custom_eeprom: true,
    custom_fix: true,
    comment: <<EOF
The number of milliseconds to spend braking before starting to drive forward.

This setting should be a multiple of 5 (JRK_BRAKE_DURATION_UNITS) and be
between 0 and 5 * 255 (JRK_MAX_ALLOWED_BRAKE_DURATION).
EOF
  },
  {
    name: 'brake_duration_reverse',
    type: :uint32_t,
    overridable: true,
    max: 'JRK_MAX_ALLOWED_BRAKE_DURATION',
    custom_eeprom: true,
    custom_fix: true,
    comment: <<EOF
The number of milliseconds to spend braking before starting to drive in
reverse.

This setting should be a multiple of 5 (JRK_BRAKE_DURATION_UNITS) and be
between 0 and 5 * 255 (JRK_MAX_ALLOWED_BRAKE_DURATION).
EOF
  },
  {
    name: 'max_current_forward',
    type: :uint16_t,
    default: 0,
    overridable: true,
    comment: <<EOF
This is the maximum current while driving forward.  If the current exceeds
this value, the jrk will trigger a "Max. current exceeded" error.

A value of 0 means no limit.

For the umc04a/umc05a jrks, the units of this setting are in milliamps.
EOF
  },
  {
    name: 'max_current_reverse',
    type: :uint16_t,
    default: 0,
    overridable: true,
    comment: <<EOF
This is the maximum current while driving in reverse.  If the current exceeds
this value, the jrk will trigger a "Max. current exceeded" error.

A value of 0 means no limit.

For the umc04a/umc05a jrks, the units of this setting are in milliamps.
EOF
  },
  {
    name: 'coast_when_off',
    type: :bool,
    overridable: true,
    address: 'JRK_SETTING_OPTIONS_BYTE3',
    bit_address: 'JRK_OPTIONS_BYTE3_COAST_WHEN_OFF',
    comment:
      "By default, the jrk drives both motor outputs low when the motor is\n" \
      "stopped (duty cycle is zero or there is an error), causing it to brake.\n" \
      "If enabled, this setting causes it to instead tri-state both inputs, making\n" \
      "the motor coast."
  },
  {
    name: 'error_enable',
    type: :uint16_t,
    comment: <<EOF
This setting is a bitmap specifying which errors are enabled.

This includes errors that are enabled and latched.

The JRK_ERROR_* macros specify the bits in the bitmap.  Certain errors are
always enabled, so the jrk ignores the bits for those errors.
EOF
  },
  {
    name: 'error_latch',
    type: :uint16_t,
    comment: <<EOF
This setting is a bitmap specifying which errors are enabled and latched.

When a latched error occurs, the jrk will not clear the corresponding error
bit (and thus not restart the motor) until the jrk receives a command to
clear the error bits.

The JRK_ERROR_* macros specify the bits in the bitmap.  Certain errors are
always latched if they are enabled, so the jrk ignores the bits for those
errors.
EOF
  },
  {
    name: 'error_hard',
    type: :uint16_t,
    comment: <<EOF
This setting is a bitmap specifying which errors are hard errors.

If a hard error is enabled and it happens, the jrk will set the motor's duty
cycle to 0 immediately without respecting deceleration limits.

The JRK_ERROR_* macros specify the bits in the bitmap.  Certain errors are
always hard errors, so the jrk ignores the bits for those errors.
EOF
  },
  {
    name: 'vin_calibration',
    english_name: 'VIN calibration',
    type: :int16_t,
    range: -500..500,
    comment: <<EOF
The firmware uses this calibration factor when calculating the VIN voltage.
One of the steps in the process is to multiply the VIN voltage reading by
(825 + vin_calibration).

So for every 8 counts that you add or subtract from the vin_calibration
setting, you increase or decrease the VIN voltage reading by about 1%.
EOF
  },
  {
    name: 'disable_i2c_pullups',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_DISABLE_I2C_PULLUPS',
    comment: <<EOF
This option disables the internal pull-up resistors on the SDA/AN and SCL
pins if those pins are being used for I2C communication.
EOF
  },
  {
    name: 'analog_sda_pullup',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_ANALOG_SDA_PULLUP',
    comment: <<EOF
This option enables the internal pull-up resistor on the SDA/AN pin if it is
being used as an analog input.
EOF
  },
  {
    name: 'always_analog_sda',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_ALWAYS_ANALOG_SDA',
    comment: <<EOF
This option causes the jrk to perform analog measurements on the SDA/AN pin
and configure SCL as a potentiometer power pin even if the "Input mode"
setting is not "Analog".
EOF
  },
  {
    name: 'always_analog_fba',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_ALWAYS_ANALOG_SDA',
    comment: <<EOF
This option causes the jrk to perform analog measurements on the FBA pin
even if the "Feedback mode" setting is not "Analog".
EOF
  },
  {
    name: 'tachometer_mode',
    type: :enum,
    max: 'JRK_TACHOMETER_MODE_PULSE_TIMING',
    default: 'JRK_TACHOMETER_MODE_PULSE_COUNTING',
    english_default: 'pulse counting',
    comment: <<EOF
This settings specifies what kind of tachometer measurement to perform
on the FBT pin.

JRK_TACHOMETER_MODE_PULSE_COUNTING means the jrk will count the number of
rising edges on the pin, and is more suitable for fast tachometers.

JRK_TACHOMETER_MODE_PULSE_TIMING means the jrk will measure the pulse width
(duration) of pulses on the pin, and is more suitable for slow tachometers.
EOF
  },
  {
    name: 'tachometer_pulse_timing_clock',
    type: :enum,
    english_default: '1.5 MHz',
    default: 'JRK_PULSE_TIMING_CLOCK_1_5',
    max: 'JRK_PULSE_TIMING_CLOCK_24',
    address: 'JRK_SETTING_TACHOMETER_PULSE_TIMING_OPTIONS',
    bit_address: 'JRK_TACHOMETER_PULSE_TIMING_OPTIONS_CLOCK',
    mask: 'JRK_TACHOMETER_PULSE_TIMING_OPTIONS_CLOCK_MASK',
    comment: <<EOF
This specifies the speed of the clock (in MHz) to use for pulse timing on the
FBT pin.  The options are:

- JRK_PULSE_TIMING_CLOCK_1_5: 1.5 MHz
- JRK_PULSE_TIMING_CLOCK_3: 3 MHz
- JRK_PULSE_TIMING_CLOCK_6: 6 MHz
- JRK_PULSE_TIMING_CLOCK_12: 12 MHz
- JRK_PULSE_TIMING_CLOCK_24: 24 MHz
- JRK_PULSE_TIMING_CLOCK_48: 48 MHz
EOF
  },
  {
    name: 'tachometer_pulse_timing_polarity',
    type: :bool,
    address: 'JRK_SETTING_TACHOMETER_PULSE_TIMING_OPTIONS',
    bit_address: 'JRK_TACHOMETER_PULSE_TIMING_OPTIONS_POLARITY',
    comment: <<EOF
By default, the pulse timing mode on the FBT pin measures the time of
high pulses.  When true, this option causes it to measure low pulses.
EOF
  },
  {
    name: 'tachometer_pulse_timing_timeout',
    type: :uint16_t,
    default: 100,
    comment: <<EOF
The pulse timing mode for the FBT pin will assume the motor has stopped, and
start recording maximum-width pulses if it has not seen any pulses in this
amount of time.
EOF
  },
  {
    name: 'tachometer_averaging_count',
    type: :uint8_t,
    min: 1,
    max: 'JRK_MAX_ALLOWED_TACHOMETER_AVERAGING_COUNT',
    default: 1,
    comment: <<EOF
The number of consecutive tachometer readings to average together in pulse
timing mode or to add together in pulse counting mode.
EOF
  },
  {
    name: 'tachometer_divider_exponent',
    type: :uint8_t,
    default: 0,
    range: 0..15,
    address: 'JRK_SETTING_TACHOMETER_DIVIDER_EXPONENT',
    comment: <<EOF
This setting specifies how many bits to shift the raw tachomter reading to
the right before using it to calculate the "feedback" variable.  The
default value is 0.
EOF
  },
]
