Settings = [
  {
    name: 'input_mode',
    type: :enum,
    max: 'JRK_INPUT_MODE_RC',
    default: 'JRK_INPUT_MODE_SERIAL',
    default_is_zero: true,
    english_default: 'serial',
    comment: <<EOF
The input mode setting specifies how you want to control the Jrk.  It
determines the definition of the input and target variables.  The input
variable is a raw measurement of the Jrk's input.  The target variable is
the desired state of the system's output, and feeds into the PID feedback
algorithm.

- If the input mode is "Serial" (JRK_INPUT_MODE_SERIAL), the Jrk gets its
  input and target settings over its USB, serial, or I2C interfaces.  You
  can send Set Target commands to the Jrk to set both the input and target
  variables.

- If the input mode is "Analog voltage" (JRK_INPUT_MODE_ANALOG), the Jrk gets
  it input variable by reading the voltage on its SDA/AN pin.  A signal level
  of 0 V corresponds to an input value of 0, and a signal level of 5 V
  corresponds to an input value of 4092.  The Jrk uses its input scaling
  feature to set the target variable.

- If the input mode is "RC" (JRK_INPUT_MODE_RC), the Jrk
  gets it input variable by reading RC pulses on its RC pin.  The input value
  is the width of the most recent pulse, in units of 2/3 microseconds.  The
  Jrk uses its input scaling feature to set the target variable.
EOF
  },
  {
    name: 'input_error_minimum',
    type: :uint16_t,
    range: 0..4095,
    comment: <<EOF
If the raw input value is below this value, it causes an input disconnect
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
This is one of the input scaling parameters that determines how the Jrk
calculates its target value from its raw input.

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
    comment: <<END
If the input mode is JRK_INPUT_MODE_ANALOG, this setting causes the Jrk to
drive its input potentiometer power pin (SCL) low once per PID period after
measuring SDA/AN.  If the voltage on SDA/AN does not drop by at least a
factor of two while SCL is low, then the Jrk will report an
"Input disconnect" error (if that error is enabled).
END
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
    default: 'JRK_FEEDBACK_MODE_NONE',
    english_default: 'none',
    max: 'JRK_FEEDBACK_MODE_FREQUENCY',
    comment: <<EOF
The feedback mode setting specifies whether the Jrk is using feedback from
the output of the system, and if so defines what type of feedback to use.

- If the feedback mode is "None" (JRK_FEEDBACK_MODE_NONE), feedback and PID
  calculations are disabled, and the Jrk will do open-loop control.
  The duty cycle target variable is always equal to the target variable
  minus 2048, instead of being the result of a PID calculation.  This means
  that a target of 2648 corresponds to driving the motor full speed forward,
  2048 is stopped, and 1448 is full-speed reverse.

- If the feedback mode is "Analog" (JRK_FEEDBACK_MODE_ANALOG), the Jrk gets
  its feedback by measuring the voltage on the FBA pin.  A level of 0 V
  corresponds to a feedback value of 0, and a level of 5 V corresponds to a
  feedback value of 4092.  The feedback scaling algorithm computes the scaled
  feedback variable, and the PID algorithm uses the scaled feedback and the
  target to compute the duty cycle target.

- If the feedback mode is "Frequency (speed control)"
  (JRK_FEEDBACK_MODE_FREQUENCY), the Jrk gets it feedback by measuring the
  frequency of a digital signal on the FBT pin.  See the fbt_method setting.
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
If the raw feedback value exceeds this value, it causes a
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
    comment: <<END
If the feedback mode is JRK_FEEDBACK_MODE_ANALOG, this setting causes the
Jrk to drive its feedback potentiometer power pin (AUX) low once per PID
period after measuring FBA.  If the voltage on the FBA pin does not drop
by at least a factor of two while AUX is low, then the Jrk will report a
"Feedback disconnect" error (if that error is enabled).
END
  },
  {
    name: 'feedback_dead_zone',
    type: :uint8_t,
    comment: <<EOF
The Jrk sets the duty cycle target to zero and resets the integral
whenever the magnitude of the error is smaller than this setting. This is
useful for preventing the motor from driving when the target is very close to
scaled feedback.

The Jrk uses hysteresis to keep the system from simply riding the edge of the
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
      "around, so that 0 is next to 4095.  The Jrk will know how to take the\n" \
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
The serial mode determines how bytes are transferred between the Jrk's UART
(TX and RX pins), its two USB virtual serial ports (the command port and the
TTL Port), and its serial command processor.

- If the serial mode is "USB dual port" (JRK_SERIAL_MODE_USB_DUAL_PORT), the
  command port can be used to send commands to the Jrk and receive responses
  from it, while the TTL port can be used to send and receives bytes on the
  TX and RX lines.  The baud rate set by the USB host on the TTL port
  determines the baud rate used on the TX and RX lines.

- If the serial mode is "USB chained" (JRK_SERIAL_MODE_USB_CHAINED), the
  command port can be used to both transmit bytes on the TX line and send
  commands to the Jrk.  The Jrk's responses to those commands will be sent
  to the command port but not the TX line.  If the RX line is enabled as a
  serial line, bytes received on the RX line will be sent to the command
  port but will not be interpreted as command bytes by the Jrk.  The baud
  rate set by the USB host on the command port determines the baud rate
  used on the TX and RX lines.

- If the serial mode is "UART" (JRK_SERIAL_MODE_UART), the TX and RX lines
  can be used to send commands to the Jrk and receive responses from it.  Any
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
This is the serial device number used in the Pololu protocol on the Jrk's
serial interfaces, and the I2C device address used on the Jrk's I2C
interface.

By default, the Jrk only pays attention to the lower 7 bits of this setting,
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
By default, if the Jrk is powered from a USB bus that is in suspend mode
(e.g. the computer is sleeping) and VIN power is not present, it will go to
sleep to reduce its current consumption and comply with the USB
specification.  If you enable the "Never sleep" option, the Jrk will never go
to sleep.
EOF
  },
  {
    name: 'serial_enable_crc',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_SERIAL_ENABLE_CRC',
    comment: <<EOF
If set to true, the Jrk requires a 7-bit CRC byte at the end of each serial
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
If enabled, the Jrk's Pololu protocol will require a 14-bit device number to
be sent with every command.  This option allows you to put more than 128 Jrk
devices on one serial bus.
EOF
  },
  {
    name: 'serial_disable_compact_protocol',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_SERIAL_DISABLE_COMPACT_PROTOCOL',
    comment: <<EOF
If enabled, the Jrk will not respond to compact protocol commands.
EOF
  },
  {
    name: 'proportional_multiplier',
    type: :uint16_t,
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
    max: 18,
    comment:
      "The allowed range of this setting is 0 to 18.\n" \
      "For more information, see the proportional_multiplier documentation."
  },
  {
    name: 'integral_multiplier',
    type: :uint16_t,
    max: 1023,
    comment:
      "The allowed range of this setting is 0 to 1023.\n\n" \
      "In the PID algorithm, the integral variable (known as error sum)\n" \
      "is multiplied by a number called the integral coefficient to\n" \
      "determine its effect on the motor duty cycle.\n\n" \
      "The integral coefficient is defined by this mathematical expression:\n" \
      "  integral_multiplier / 2^(integral_exponent)\n\n" \
      "Note: On the original Jrks (Jrk 12v12 and Jrk 21v3), the formula was\n" \
      "different.  Those Jrks added 3 to the integral_exponent before using\n" \
      "it as a power of 2."
  },
  {
    name: 'integral_exponent',
    type: :uint8_t,
    max: 18,
    comment:
      "The allowed range of this setting is 0 to 18.\n" \
      "For more information, see the integral_multiplier documentation."
  },
  {
    name: 'derivative_multiplier',
    type: :uint16_t,
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
    max: 18,
    comment:
      "The allowed range of this setting is 0 to 18.\n" \
      "For more information, see the derivative_multiplier documentation.",
  },
  {
    name: 'pid_period',
    type: :uint16_t,
    range: 1..8191,
    default: 10,
    comment: <<EOF
The PID period specifies how often the Jrk should calculate its input and
feedback, run its PID calculation, and update the motor speed, in units of
milliseconds.  This period is still used even if feedback and PID are
disabled.
EOF
  },
  {
    name: 'integral_divider_exponent',
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
    default: 1000,
    max: 0x7FFF,
    comment: <<EOF
The PID algorithm prevents the absolute value of the integral variable
(also known as error sum) from exceeding this limit.  This can help limit
integral wind-up.  The limit can range from 0 to 32767.

Note that the maximum value of the integral term can be computed as the
integral coefficient times the integral limit: if this is very small
compared to 600 (maximum duty cycle), the integral term will have at most
a very small effect on the duty cycle.
EOF
  },
  {
    name: 'reset_integral',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE3',
    bit_address: 'JRK_OPTIONS_BYTE3_RESET_INTEGRAL',
    comment:
      "If this setting is set to true, the PID algorithm will reset the integral\n" \
      "variable (also known as error sum) whenever the absolute value of the\n" \
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
    name: 'hard_overcurrent_threshold',
    type: :uint8_t,
    default: 1,
    min: 1,
    products: 'product != JRK_PRODUCT_UMC06A',
    comment: <<EOF
This is the number of consecutive PID periods where the the hardware current
chopping must occur before the Jrk triggers a "Hard overcurrent\" error.
The default of 1 means that any current chopping is an error.  You can set it
to a higher value if you expect some current chopping to happen (e.g. when
starting up) but you still want to it to be an error when your motor leads
are shorted out.

This setting is not used on the umc06a since it cannot sense when hardware
current chopping happens.
EOF
  },
  {
    name: 'current_offset_calibration',
    type: :int16_t,
    default: 0,
    comment: <<EOF
You can use this current calibration setting to correct current measurements
and current limit settings.

The current sense circuitry on a umc04a/umc05a Jrks produces a constant
voltage of about 50 mV (but with large variations from unit to unit) when the
motor driver is powered, even if there is no current flowing through the
motor.  This offset must be subtracted from analog voltages representing
current limits or current measurements as one of the first steps for
converting those voltages to amps.

For the umc04a/umc05a Jrk models, this setting is defined by the formula:

  current_offset_calibration = (voltage offset in millivolts - 50) * 16

For the umc04a/umc05a Jrk models, this setting should be between -800
(for an offset of 0 mV) and 800 (for an offset of 100 mV).

For the umc06a, this setting can be any int16_t value and has units of mV/16.
EOF
  },
  {
    name: 'current_scale_calibration',
    type: :int16_t,
    default: 0,
    comment: <<EOF
You can use this current calibration setting to correct current measurements
and current limit settings that are off by a constant percentage.

For the umc04a/umc05a models, the algorithm for calculating currents in
milliamps involves multiplying the current by
(1875 + current_scale_calibration).
This setting must be between -1875 and 1875.

For the umc06a models, the algorithm for calculating currents in
milliamps involves multiplying the current by
(1136 + current_scale_calibration).
This setting must be between -1136 and 1136.

The default current_scale_calibration value is 0.
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
    range: 1..600,
    default: 600,
    comment: <<EOF
If the feedback is beyond the range specified by the feedback error
minimum and feedback error maximum values, then the duty cycle's magnitude
cannot exceed this value.

This option helps limit possible damage to systems by reducing the maximum
duty cycle whenever the feedback is outside the range specified by the
feedback error minimum and feedback error maximum values.  This can be
used, for example, to slowly bring a system back into its valid range of
operation when it is dangerously near a limit.  The Feedback disconnect
error should be disabled when this option is used.
EOF
  },
  {
    name: 'max_acceleration_forward',
    type: :uint16_t,
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
    max: 600,
    default: 600,
    comment: <<EOF
This is the maximum allowed duty cycle in the reverse direction.

Negative duty cycles cannot go below this number negated.

A value of 600 means 100%.
EOF
  },
  {
    name: 'encoded_hard_current_limit_forward',
    type: :uint16_t,
    # the default is actually different for each device
    max: 95,
    products: 'product != JRK_PRODUCT_UMC06A',
    comment: <<EOF
Sets the current limit to be used when driving forward.

This setting is not actually a current, it is an encoded value telling
the Jrk how to set up its current limiting hardware.

This setting is not used for the umc06a, since it does not have a
configurable hardware current limiting.

The correspondence between this setting and the actual current limit
in milliamps depends on what product you are using.  See also:

- jrk_current_limit_decode()
- jrk_current_limit_encode()
- jrk_get_recommended_encoded_hard_current_limits()
EOF
  },
  {
    name: 'encoded_hard_current_limit_reverse',
    type: :uint16_t,
    max: 95,
    products: 'product != JRK_PRODUCT_UMC06A',
    comment:
      "Sets the current limit to be used when driving in reverse.\n" \
      "See the documentation of encoded_hard_current_limit_forward."
  },
  {
    name: 'brake_duration_forward',
    type: :uint32_t,
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
    name: 'soft_current_limit_forward',
    type: :uint16_t,
    default: 0,
    comment: <<EOF
This is the maximum current while driving forward.  If the current exceeds
this value, the Jrk will trigger a "Max. current exceeded" error.

A value of 0 means no limit.

The units for this setting are milliamps.
EOF
  },
  {
    name: 'soft_current_limit_reverse',
    type: :uint16_t,
    default: 0,
    comment: <<EOF
This is the maximum current while driving in reverse.  If the current exceeds
this value, the Jrk will trigger a "Max. current exceeded" error.

A value of 0 means no limit.

The units for this setting are milliamps.
EOF
  },
  {
    name: 'soft_current_regulation_level_forward',
    type: :uint16_t,
    default: 0,
    products: 'product == JRK_PRODUCT_UMC06A',
    comment: <<EOF
If this setting is non-zero and the Jrk is driving the motor forward, the Jrk
will attempt to prevent the motor current from exceeding this value by
limiting the duty cycle using a simple linear formula.

A value of 0 disables software current regulation.

This feature is not supported on the umc04a/umc05a Jrks since they have
hardware current regulation.

The units for this setting are milliamps.
EOF
  },
  {
    name: 'soft_current_regulation_level_reverse',
    type: :uint16_t,
    default: 0,
    products: 'product == JRK_PRODUCT_UMC06A',
    comment: <<EOF
If this setting is non-zero and the Jrk is driving the motor in reverse, the
Jrk will attempt to prevent the motor current from exceeding this value by
limiting the duty cycle using a simple linear formula.

A value of 0 disables software current regulation.

This feature is not supported on the umc04a/umc05a Jrks since they have
hardware current regulation.

The units for this setting are milliamps.
EOF
  },
  {
    name: 'coast_when_off',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE3',
    bit_address: 'JRK_OPTIONS_BYTE3_COAST_WHEN_OFF',
    comment:
      "By default, the Jrk drives both motor outputs low when the motor is\n" \
      "stopped (duty cycle is zero or there is an error), causing it to brake.\n" \
      "If enabled, this setting causes it to instead tri-state both outputs,\n" \
      "making the motor coast."
  },
  {
    name: 'error_enable',
    type: :uint16_t,
    comment: <<EOF
This setting is a bitmap specifying which errors are enabled.

This includes errors that are enabled and latched.

The JRK_ERROR_* macros specify the bits in the bitmap.  Certain errors are
always enabled, so the Jrk ignores the bits for those errors.
EOF
  },
  {
    name: 'error_latch',
    type: :uint16_t,
    comment: <<EOF
This setting is a bitmap specifying which errors are enabled and latched.

When a latched error occurs, the Jrk will not clear the corresponding error
bit (and thus not restart the motor) until the Jrk receives a command to
clear the error bits.

The JRK_ERROR_* macros specify the bits in the bitmap.  Certain errors are
always latched if they are enabled, so the Jrk ignores the bits for those
errors.
EOF
  },
  {
    name: 'error_hard',
    type: :uint16_t,
    comment: <<EOF
This setting is a bitmap specifying which errors are hard errors.

If a hard error is enabled and it happens, the Jrk will set the motor's duty
cycle to 0 immediately without respecting deceleration limits.

The JRK_ERROR_* macros specify the bits in the bitmap.  Certain errors are
always hard errors, so the Jrk ignores the bits for those errors.
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
This option causes the Jrk to perform analog measurements on the SDA/AN pin
and configure SCL as a potentiometer power pin even if the "Input mode"
setting is not "Analog".
EOF
  },
  {
    name: 'always_analog_fba',
    type: :bool,
    address: 'JRK_SETTING_OPTIONS_BYTE1',
    bit_address: 'JRK_OPTIONS_BYTE1_ALWAYS_ANALOG_FBA',
    comment: <<EOF
This option causes the Jrk to perform analog measurements on the FBA pin
even if the "Feedback mode" setting is not "Analog".
EOF
  },
  {
    name: 'fbt_method',
    type: :enum,
    max: 'JRK_FBT_METHOD_PULSE_TIMING',
    default: 'JRK_FBT_METHOD_PULSE_COUNTING',
    english_default: 'pulse counting',
    comment: <<EOF
This settings specifies what kind of pulse measurement to perform
on the FBT pin.

JRK_FBT_METHOD_PULSE_COUNTING means the Jrk will count the number of
rising edges on the pin, and is more suitable for fast tachometers.

JRK_FBT_METHOD_PULSE_TIMING means the Jrk will measure the pulse width
(duration) of pulses on the pin, and is more suitable for slow tachometers.
EOF
  },
  {
    name: 'fbt_timing_clock',
    type: :enum,
    english_default: '1.5 MHz',
    default: 'JRK_FBT_TIMING_CLOCK_1_5',
    max: 'JRK_FBT_TIMING_CLOCK_24',
    address: 'JRK_SETTING_FBT_OPTIONS',
    bit_address: 'JRK_FBT_OPTIONS_TIMING_CLOCK',
    mask: 'JRK_FBT_OPTIONS_TIMING_CLOCK_MASK',
    comment: <<EOF
This specifies the speed of the clock (in MHz) to use for pulse timing on the
FBT pin.  The options are:

- JRK_FBT_TIMING_CLOCK_1_5: 1.5 MHz
- JRK_FBT_TIMING_CLOCK_3: 3 MHz
- JRK_FBT_TIMING_CLOCK_6: 6 MHz
- JRK_FBT_TIMING_CLOCK_12: 12 MHz
- JRK_FBT_TIMING_CLOCK_24: 24 MHz
- JRK_FBT_TIMING_CLOCK_48: 48 MHz
EOF
  },
  {
    name: 'fbt_timing_polarity',
    type: :bool,
    address: 'JRK_SETTING_FBT_OPTIONS',
    bit_address: 'JRK_FBT_OPTIONS_TIMING_POLARITY',
    comment: <<EOF
By default, the pulse timing mode on the FBT pin measures the time of
high pulses.  When true, this option causes it to measure low pulses.
EOF
  },
  {
    name: 'fbt_timing_timeout',
    type: :uint16_t,
    default: 100,
    min: 1,
    max: 60000,
    comment: <<EOF
The pulse timing mode for the FBT pin will assume the motor has stopped, and
start recording maximum-width pulses if it has not seen any pulses in this
amount of time.
EOF
  },
  {
    name: 'fbt_samples',
    type: :uint8_t,
    min: 1,
    max: 'JRK_MAX_ALLOWED_FBT_SAMPLES',
    default: 1,
    comment: <<EOF
The number of consecutive FBT measurements to average together in pulse
timing mode or to add together in pulse counting mode.
EOF
  },
  {
    name: 'fbt_divider_exponent',
    type: :uint8_t,
    default: 0,
    range: 0..15,
    address: 'JRK_SETTING_FBT_DIVIDER_EXPONENT',
    comment: <<EOF
This setting specifies how many bits to shift the raw tachomter reading to
the right before using it to calculate the "feedback" variable.  The
default value is 0.
EOF
  },
]
