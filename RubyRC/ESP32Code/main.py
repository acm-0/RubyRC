# Rui Santos & Sara Santos - Random Nerd Tutorials
# Complete project details at https://RandomNerdTutorials.com/micropython-esp32-bluetooth-low-energy-ble/

from micropython import const
import asyncio
import aioble
import bluetooth
import struct
import time
import os
from machine import Pin, PWM
from random import randint

# Map Seeed ESP32 pins to Micropython expectations.  Use only Dx when assigning pins
D0 = 2
D1 = 3
D2 = 4
D3 = 5
D4 = 6
D5 = 7
D6 = 12 # Specualation, does not actually work.   Could be because D6 and D7 are 
D7 = 11 # But pin behaves strangely, suggest not to use       for UART Tx and Rx
D8 = 8
D9 = 9
D10 = 10

#Servo positions default and current values - overwritten by config.txt if it exists
# Johnson
FORWARD = 123
FORWARDDEFAULT = 123
NEUTRAL = 95
NEUTRALDEFAULT = 95
REVERSE = 60
REVERSEDEFAULT = 60
# Throttle
THROTTLEOFF = 0
THROTTLEOFFDEFAULT = 9
THROTTLEMAX = 100
THROTTLEMAXDEFAULT=100

#Bluetooth codes
FORWARDCOMMAND = 10
NEUTRALCOMMAND = 20
REVERSECOMMAND = 30

# Init LED
led = Pin(D1, Pin.OUT)
led.value(0)
led_enable = 1

# Init Servos
throttle_servo = PWM(Pin(D9))
throttle_servo.freq(50)
johnson_bar_servo = PWM(Pin(D10))
johnson_bar_servo.freq(50)

# Function to set the servo angle
# Pulse width for 0 degrees is around 0.5ms (duty_u16 = 1638)
# Pulse width for 180 degrees is around 2.5ms (duty_u16 = 8191)
# These values might need slight adjustment for your specific servo.
def set_servo_angle(servo, angle):
    # Map the angle (0-180) to the appropriate duty cycle range
    # 0 degrees corresponds to a duty_u16 of ~1638
    # 180 degrees corresponds to a duty_u16 of ~8191
    # You can fine-tune these min/max duty cycle values based on your servo's specifications
    min_duty = 1638  # Example: 0.5ms pulse at 50Hz
    max_duty = 8191  # Example: 2.5ms pulse at 50Hz
    if angle < 0: angle = 0
    if angle > 180: angle = 180
    duty = int(min_duty + (angle / 180) * (max_duty - min_duty))
#    print(angle, duty)
    servo.duty_u16(duty)
    
johnson_bar_position = NEUTRAL
set_servo_angle(johnson_bar_servo,johnson_bar_position)    
throttle_position = 0
set_servo_angle(throttle_servo,throttle_position)
previous_interrupt_time = 0
axle_delta = 0
#got_interrupt = False

def sensor_isr(pin):
    global previous_interrupt_time, axle_delta
    interrupt_time = time.ticks_ms()
    axle_delta = interrupt_time - previous_interrupt_time
    previous_interrupt_time = interrupt_time
#    got_interrupt = True
    if led_enable: led.value(1-led.value())

sensor = Pin(D4, Pin.IN)
sensor.irq(trigger=Pin.IRQ_FALLING, handler=sensor_isr)

# Init random value
value = 0

# See the following for generating UUIDs:
# https://www.uuidgenerator.net/
_BLE_SERVICE_UUID = bluetooth.UUID('19b10000-e8f2-537e-4f6c-d104768a1214')
#_BLE_SENSOR_CHAR_UUID = bluetooth.UUID('19b10001-e8f2-537e-4f6c-d104768a1214')
_BLE_LED_ENABLE_UUID = bluetooth.UUID('19b10001-e8f2-537e-4f6c-d104768a1214')
_BLE_JOHNSON_UUID = bluetooth.UUID('19b10002-e8f2-537e-4f6c-d104768a1214')
_BLE_THROTTLE_UUID = bluetooth.UUID('19b10003-e8f2-537e-4f6c-d104768a1214')
_BLE_READSPEED_UUID = bluetooth.UUID('19b10004-e8f2-537e-4f6c-d104768a1214')
_BLE_SETSERVODEFAULTS_UUID = bluetooth.UUID('19b10005-e8f2-537e-4f6c-d104768a1214')

# How frequently to send advertising beacons.
_ADV_INTERVAL_MS = 250_000

# Register GATT server, the service and characteristics
ble_service = aioble.Service(_BLE_SERVICE_UUID)
led_enable_characteristic = aioble.Characteristic(ble_service, _BLE_LED_ENABLE_UUID, read=True, write=True, capture=True)
johnson_characteristic = aioble.Characteristic(ble_service, _BLE_JOHNSON_UUID, read=True, write=True, notify=False, capture=True)
throttle_characteristic = aioble.Characteristic(ble_service, _BLE_THROTTLE_UUID, read=True, write=True, notify=False, capture=True)
readspeed_characteristic = aioble.Characteristic(ble_service, _BLE_READSPEED_UUID, read=True, write=False, notify=True, capture=False)
setservos_characteristic = aioble.Characteristic(ble_service, _BLE_SETSERVODEFAULTS_UUID, read=True, write=True, notify=False, capture=True)

# Register service(s)
aioble.register_services(ble_service)

# Helper to encode the data characteristic UTF-8
#def _encode_data(data):
#    return str(data).encode('utf-8')

def _encode_data(data):
    return struct.pack("<I", data)  # 32-bit unsigned int (little-endian)

# Helper to decode the LED characteristic encoding (bytes).
def _decode_data(data):
    try:
        if data is not None:
            # Decode the UTF-8 data
            number = int.from_bytes(data, 'big')
            return number
    except Exception as e:
        print("Error decoding temperature:", e)
        return None

def decode_unknown(data):
    """
    Try to decode an unknown data object into a number or text string.
    Handles bytes, bytearray, str, and numeric types.
    Returns the decoded value (int, float, or str).
    """
    # --- Handle None ---
    if data is None:
        return None

    # --- If already a number ---
    if isinstance(data, (int, float)):
        return data

    # --- If it's bytes or bytearray ---
    if isinstance(data, (bytes, bytearray)):
        if len(data) == 1: # It's an 8 bit integer
            return data[0]
        # Try text decoding
        try:
            text = data.decode('utf-8')
            # Try to interpret text as a number
            try:
                if '.' in text:
                    return float(text)
                else:
                    return int(text)
            except ValueError:
                return text.strip()  # just return as text
        except UnicodeDecodeError:
            # As fallback, try hex or repr
			return data.hex()

    # --- If it's already a string ---
    if isinstance(data, str):
        # Try number first
        try:
            if '.' in data:
                return float(data)
            else:
                return int(data)
        except ValueError:
            return data.strip()

    # --- Fallback: convert to string ---
    return str(data)
        
# Serially wait for connections. Don't advertise while a central is connected.
async def peripheral_task():
    while True:
        try:
            async with await aioble.advertise(
                _ADV_INTERVAL_MS,
                name="RUBY ESP32",
                services=[_BLE_SERVICE_UUID],
                ) as connection:
                    print("Connection from", connection.device)
                    await connection.disconnected()             
        except asyncio.CancelledError:
            # Catch the CancelledError
            print("Peripheral task cancelled")
        except Exception as e:
            print("Error in peripheral_task:", e)
        finally:
            # Ensure the loop continues to the next iteration
            await asyncio.sleep_ms(100)

# Get new value and update characteristic
async def readspeed_task():
    global axle_delta, previous_interrupt_time
    while True:
        if time.ticks_ms() - previous_interrupt_time > 500 :
            value = 5000
        else :
            value = axle_delta
        readspeed_characteristic.write(_encode_data(value), send_update=True)
        await asyncio.sleep_ms(50)

async def setservodefaults_task():
    global FORWARD, FORWARDDEFAULT, NEUTRAL, NEUTRALDEFAULT, REVERSE, REVERSEDEFAULT, THROTTLEOFF, THROTTLEOFFDEFAULT, THROTTLEMAX, THROTTLEMAXDEFAULT
    byte_data = struct.pack('5B', FORWARD, NEUTRAL, REVERSE, THROTTLEOFF, THROTTLEMAX)
    setservos_characteristic.write(byte_data)
    while True:
        try:
            connection, data = await throttle_characteristic.written()
            FORWARD, NEUTRAL, REVERSE, THROTTLEOFF, THROTTLEMAX = struct.unpack('<5B', data)
        except asyncio.CancelledError:
            # Catch the CancelledError
            print("Peripheral task cancelled")
        except Exception as e:
            print("Error in peripheral_task:", e)
        finally:
            # Ensure the loop continues to the next iteration
            await asyncio.sleep_ms(100)        
        
        
async def sensor_task():
    while True:
        # Simulate reading a sensor
        temp = random.randint(20, 30)
        print(f"Updating sensor value to: {temp}°C")
        
        # Write to the characteristic. 
        # When a phone reads this characteristic, it gets this value.
        temp_char.write(struct.pack("<h", temp * 100))
        
        await asyncio.sleep(5)        
        
        
        

async def wait_for_throttle_write():
    global throttle_position
    while True:
        try:
            connection, data = await throttle_characteristic.written()
            print(data)
            print(type)
            data = decode_unknown(data)
            print('Connection: ', connection)
            print('Data: ', data)
            if isinstance(data,int) :
                throttle_position = data
                print("hello")
                set_servo_angle(throttle_servo,throttle_position)
        except asyncio.CancelledError:
            # Catch the CancelledError
            print("Peripheral task cancelled")
        except Exception as e:
            print("Error in peripheral_task:", e)
        finally:
            # Ensure the loop continues to the next iteration
            await asyncio.sleep_ms(100)
            
async def wait_for_johnson_write():
    global johnson_bar_position
    while True:
        try:
            connection, data = await johnson_characteristic.written()
            print(data)
            print(type)
            data = decode_unknown(data)
            if data == FORWARDCOMMAND: johnson_bar_position = FORWARD
            elif data == REVERSECOMMAND: johnson_bar_position = REVERSE
            elif data == NEUTRALCOMMAND: johnson_bar_position = NEUTRAL
            print('Connection: ', connection)
            print('Data: ', data)
            set_servo_angle(johnson_bar_servo,johnson_bar_position)
        except asyncio.CancelledError:
            # Catch the CancelledError
            print("Peripheral task cancelled")
        except Exception as e:
            print("Error in peripheral_task:", e)
        finally:
            # Ensure the loop continues to the next iteration
            await asyncio.sleep_ms(100)
            
async def wait_for_led_enable_write():
    global led_enable
    while True:
        try:
            connection, data = await led_enable_characteristic.written()
#            print(data)
#            print(type)
            data = decode_unknown(data)
#            print('Connection: ', connection)
#            print('Data: ', data)
            if data == 1:
                print('Enabling red led')
                led_enable = 1
                led.value(1)
            elif data == 0:
                print('Disabling red led')
                led_enable = 0
                led.value(0)
            else:
                print('Unknown command')
                print("data: ",data)
        except asyncio.CancelledError:
            # Catch the CancelledError
            print("Peripheral task cancelled")
        except Exception as e:
            print("Error in peripheral_task:", e)
        finally:
            # Ensure the loop continues to the next iteration
            await asyncio.sleep_ms(100)
            
# Run tasks
async def main():
#    t1 = asyncio.create_task(sensor_task())
    t2 = asyncio.create_task(peripheral_task())
    t3 = asyncio.create_task(wait_for_throttle_write())
    t4 = asyncio.create_task(wait_for_johnson_write())
    t5 = asyncio.create_task(wait_for_led_enable_write())
    t6 = asyncio.create_task(readspeed_task())
    t7 = asyncio.create_task(setservodefaults_task())
    await asyncio.gather(t2)
    
import os
if "config.txt" in os.listdir():
    # Safe to read
    with open("config.txt", "r") as f:
        content = f.read()
        clean_line = content.strip()
        parts = clean_line.split(',')
        FORWARD = int(parts[0])
        NEUTRAL = int(parts[1])  # Convert back to int for use
        REVERSE = int(parts[2])
        THROTTLEOFF = int(parts[3])
        THROTTLEMAX = int(parts[4])


        print(f"FORWARD: {FORWARD} | NEUTRAL: {NEUTRAL} | REVERSE {REVERSE} | THROTTLEOFF: {THROTTLEOFF} | THROTTLEMAX: {THROTTLEMAX}")
    
else: # Save the harcoded default values
    with open("config.txt", "w") as f:
        f.write(f"{FORWARDDEFAULT},{NEUTRALDEFAULT},{REVERSEDEFAULT},{THROTTLEOFFDEFAULT},{THROTTLEMAXDEFAULT}\n")

asyncio.run(main())