import time
import threading
from pynput.mouse import Button, Controller
import csv
import numpy as np
from pynput.keyboard import Listener, KeyCode
from pynput.keyboard import Controller as keyCon

mouse = Controller()
keyboard = keyCon()

# four variables are created to
# control the auto-clicker
delay = 1
button = Button.left
start_stop_key = KeyCode(char='a')
stop_key = KeyCode(char='b')

# ENTER PIXEL COORDINATES OF MODEL NAME TEXTBOX
modelName = (1581, 528)
# ENTER DELAY BETWEEN CLICKS [s] (FOR TESTING)
keyDelay = 0.03
# ENTER DELAY ALLOWED TO CANCEL PROGRAM
cancelDelay = 2
# ENTER TEMP START, STOP, STEP
tempStart = 20
tempStop = 150.1
tempStep = 0.1
# ENTER NAME OF FILES (MAKE SURE THEYRE IN SRC FOLDER)
ifile1 = open('UJC RdsON Curve.csv', encoding='utf-8-sig')
ifile2 = open('UJC Vth Curve.csv', encoding='utf-8-sig')

DCcharacteristics = (modelName[0]-60, modelName[1]+25)
Rds_on = (modelName[0]-31, modelName[1]+64)
Vgs = (modelName[0]-33, modelName[1]+87)
updateLambda = (modelName[0]+380, modelName[1]+101)
VDmosModel = (modelName[0]+123, modelName[1]+20)
updateModel = (modelName[0]+170, modelName[1]+146)
LibManager = (modelName[0]+199, modelName[1]+23)
addModel = (modelName[0]+87, modelName[1]+65)

class ClickMouse(threading.Thread):
    
# delay and button is passed in class
# to check execution of auto-clicker
    def __init__(self, delay, button):
        super(ClickMouse, self).__init__()
        self.delay = delay
        self.button = button
        self.running = False
        self.program_running = True

    def start_clicking(self):
        self.running = True

    def stop_clicking(self):
        self.running = False

    def exit(self):
        self.stop_clicking()
        self.program_running = False

    # method to check and run loop until
    # it is true another loop will check
    # if it is set to true or not,
    # for mouse click it set to button
    # and delay.
    def run(self):
        while self.program_running:
            while self.running:
                #mouse.click(self.button)
                print('The current pointer position is {0}'.format(mouse.position))
                time.sleep(self.delay)
            time.sleep(0.1)

mouse = Controller()
click_thread = ClickMouse(delay, button)
click_thread.start()

def on_press(key):
    if key == start_stop_key:
        if click_thread.running:
            click_thread.stop_clicking()
        else:
            click_thread.start_clicking()
    elif key == stop_key:
        click_thread.exit()
        listener.stop()

with Listener(on_press=on_press) as listener:
    listener.join()
    
temps = np.around(np.arange(tempStart, tempStop, tempStep, dtype = float), decimals=1)

inputLen = len(temps)

rdsData = np.empty([inputLen, 2],dtype=float)
vthData = np.empty([inputLen, 2],dtype=float)

count = 0
reader = csv.reader(ifile1, delimiter=',')
for row in reader:
    rdsData[count] = row
    count += 1

count = 0
reader = csv.reader(ifile2, delimiter=',')
for row in reader:
    vthData[count] = row
    count += 1

count = 0
listener = Listener(on_press=on_press)
for temp in temps:
    time.sleep(keyDelay)
    mouse.position = modelName
    time.sleep(keyDelay)
    mouse.click(Button.left, 2)
    time.sleep(keyDelay)
    keyboard.type('UJC'+str(rdsData[count][0]))
    time.sleep(keyDelay)
    mouse.position = DCcharacteristics
    time.sleep(keyDelay)
    mouse.click(Button.left, 1)
    time.sleep(keyDelay)
    mouse.position = Rds_on
    time.sleep(keyDelay)
    mouse.click(Button.left, 2)
    time.sleep(keyDelay)
    keyboard.type(str(rdsData[count][1]))
    time.sleep(keyDelay)
    mouse.position = Vgs
    time.sleep(keyDelay)
    mouse.click(Button.left, 2)
    time.sleep(keyDelay)
    keyboard.type(str(vthData[count][1]))
    time.sleep(keyDelay)
    mouse.position = updateLambda
    time.sleep(keyDelay)
    mouse.click(Button.left, 1)
    time.sleep(keyDelay)
    mouse.position = VDmosModel
    time.sleep(keyDelay)
    mouse.click(Button.left, 1)
    time.sleep(keyDelay)
    mouse.position = updateModel
    time.sleep(keyDelay)
    mouse.click(Button.left, 1)
    time.sleep(keyDelay)
    mouse.position = LibManager
    time.sleep(keyDelay)
    mouse.click(Button.left, 1)
    time.sleep(keyDelay)
    mouse.position = addModel
    time.sleep(keyDelay)
    mouse.click(Button.left, 1)
    count += 1
    if count % 10 == 0:
        print('Cancel execution available')
        time.sleep(cancelDelay)
        print('Running')
    else:
        time.sleep(keyDelay)