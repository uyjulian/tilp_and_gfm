/*  TiLP - Linking program for TI calculators
 *  Copyright (C) 2001-2003 Julien BLACHE <jb@tilp.info>
 *
 *  $Id$
 *
 *  Cocoa GUI for Mac OS X
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */
 
/*
 * The code for establishing a list of available serial devices is derived from
 * Apple Sample Code (SerialPortSample). Apple is not liable for anything regarding
 * this code, according to the Apple Sample Code License.
 */

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

#include <paths.h>
#include <sys/param.h>

#include <libticalcs/calc_int.h>

#include "../src/tilp_struct.h"
#include "../src/tilp_defs.h"

#include "cocoa_config.h"
#include "cocoa_structs.h"

extern struct cocoa_objects_ptr *objects_ptr;

#import "PrefsController.h"

@implementation PrefsController

- (void)awakeFromNib
{
#ifdef OSX_DEBUG
    fprintf(stderr, "prefs => got awakeFromNib\n");
#endif
    
    // Init instance pointer
    objects_ptr->myPrefsController = self;
}

- (IBAction)prefsAdvanced:(id)sender
{
    if (sender == linkTimeoutValueStepper)
        [linkTimeoutField takeIntValueFrom:linkTimeoutValueStepper];
    else if (sender == linkTimeoutField)
        [linkTimeoutValueStepper takeIntValueFrom:linkTimeoutField];

    options.lp.timeout = [linkTimeoutField intValue];
}

- (IBAction)prefsClose:(id)sender
{
    NSString *portName;
    
// general
    
    if (NSOnState == [orderIncreasing state])
        options.ctree_sort_order = SORT_UP;
    else
        options.ctree_sort_order = SORT_DOWN;

    if (NSOnState == [sortByInfo state])
        options.ctree_sort = SORT_BY_INFO;
    else if (NSOnState == [sortByName state])
        options.ctree_sort = SORT_BY_NAME;
    else if (NSOnState == [sortBySize state])
        options.ctree_sort = SORT_BY_SIZE;
    else if (NSOnState == [sortByType state])
        options.ctree_sort = SORT_BY_TYPE;

    if (NSOnState == [multipleVarsGroup state])
        options.single_or_group = RECV_AS_GROUP;
    else
        options.single_or_group = RECV_AS_SINGLE;
    
    if (NSOnState == [pathModeFull state])
        options.path_mode = FULL_PATH;
    else
        options.path_mode = LOCAL_PATH;
    
// hardware
    
    if (NSOnState == [linkCableUGL state])
        {
            options.lp.link_type = LINK_UGL;
            
            options.lp.port = OSX_USB_PORT;
            memset(options.lp.device, 0, sizeof(options.lp.device));
        }
    else if (NSOnState == [linkCableTPU state])
        {
            options.lp.link_type = LINK_TPU;
         
            options.lp.port = OSX_USB_PORT;
            memset(options.lp.device, 0, sizeof(options.lp.device));
        }
    else if (NSOnState == [linkCableTIE state])
        {
            options.lp.link_type = LINK_TIE;
        
            options.lp.port = VIRTUAL_PORT_1;
            memset(options.lp.device, 0, sizeof(options.lp.device));
        }
    else if (NSOnState == [linkCableVTI state])
        {
            options.lp.link_type = LINK_VTI;
         
            options.lp.port = VIRTUAL_PORT_1;
            memset(options.lp.device, 0, sizeof(options.lp.device));
        }
    else if (NSOnState == [linkCableTGL state])
        {
            options.lp.link_type = LINK_TGL;
            options.lp.port = OSX_SERIAL_PORT;
        
            portName = [portNameArray objectAtIndex:[portCombo indexOfSelectedItem]];
            [portName getCString:options.lp.device];
        }
    else if (NSOnState == [linkCableSER state])
       {
            options.lp.link_type = LINK_SER;
            options.lp.port = OSX_SERIAL_PORT;

            portName = [portNameArray objectAtIndex:[portCombo indexOfSelectedItem]];
            [portName getCString:options.lp.device];
       }

// calculator

    if (NSOnState == [calcTypeV200 state])
        options.lp.calc_type = CALC_V200;
    else if (NSOnState == [calcType92p state])
        options.lp.calc_type = CALC_TI92P;
    else if (NSOnState == [calcType92 state])
        options.lp.calc_type = CALC_TI92;
    else if (NSOnState == [calcType89 state])
        options.lp.calc_type = CALC_TI89;
    else if (NSOnState == [calcType86 state])
        options.lp.calc_type = CALC_TI86;
    else if (NSOnState == [calcType85 state])
        options.lp.calc_type = CALC_TI85;
    else if (NSOnState == [calcType83p state])
        options.lp.calc_type = CALC_TI83P;
    else if (NSOnState == [calcType83 state])
        options.lp.calc_type = CALC_TI83;
    else if (NSOnState == [calcType82 state])
        options.lp.calc_type = CALC_TI82;
    else if (NSOnState == [calcType73 state])
        options.lp.calc_type = CALC_TI73;
                          
    options.auto_detect = [calcTypeProbe state];
    
// screendump
    
    if (NSOnState == [screenFormatTIFF state])
        options.screen_format = TIFF;
    else
        options.screen_format = PDF;

    if (NSOnState == [screenRenderingBlurry state])
        options.screen_blurry = TRUE;
    else
        options.screen_blurry = FALSE;
    
    if (NSOnState == [screenModeClipped state])
        options.screen_clipping = TRUE;
    else
        options.screen_clipping = FALSE;

    if (NSOnState == [screenScale2 state])
        options.screen_scaling = 2;
    else if (NSOnState == [screenScale3 state])
        options.screen_scaling = 3;
    else if (NSOnState == [screenScale4 state])
        options.screen_scaling = 4;
    else
        options.screen_scaling = 1;

// clock

    if (NSOnState == [clockModeManual state])
        options.clock_mode = CLOCK_MANUAL;
    else
        options.clock_mode = CLOCK_SYNC;

    if (NSOnState == [clockTimeFormat12 state])
        options.time_format = 12;
    else
        options.time_format = 24;

    options.date_format = [clockDateFormat indexOfSelectedItem] + 1;
    
// advanced
    
    if (NSOnState == [consoleVerbose state])
        options.console_mode = DSP_ON;
    else
        options.console_mode = DSP_OFF;
            
    ticable_set_param2(options.lp);
        
    ticable_set_cable(options.lp.link_type, &link_cable);

    ticalc_set_calc(options.lp.calc_type, &ti_calc);

    rc_save_user_prefs();

    [NSApp stopModal];

    if (portNameArray != nil)
        {
            [portNameArray release];
            portNameArray = nil;
        }
        
    if (portTypeArray != nil)
        {
            [portTypeArray release];
            portTypeArray = nil;
        }
}

- (IBAction)showPrefsSheet:(id)sender
{
    NSEnumerator *portEnumerator;
    NSString *portName;
    BOOL gotListing;
    BOOL deviceMatched = NO;

    // get the list of all serial ports
    gotListing = [self getSerialPortsList];

// general
    
    if (options.path_mode == FULL_PATH)
        [pathModeMatrix setState:NSOnState atRow:0 column:0];
    else
        [pathModeMatrix setState:NSOnState atRow:0 column:1];

    switch(options.ctree_sort)
        {
            case SORT_BY_NAME:
                [sortByMatrix setState:NSOnState atRow:0 column:0];
                break;
            case SORT_BY_TYPE:
                [sortByMatrix setState:NSOnState atRow:0 column:1];
                break;
            case SORT_BY_INFO:
                [sortByMatrix setState:NSOnState atRow:1 column:0];
                break;
            case SORT_BY_SIZE:
                [sortByMatrix setState:NSOnState atRow:1 column:1];
                break;
        }

    if (options.single_or_group == RECV_AS_GROUP)
        [multipleVarsMatrix setState:NSOnState atRow:0 column:0];
    else
        [multipleVarsMatrix setState:NSOnState atRow:0 column:1];
    
    if (options.ctree_sort_order == SORT_UP)
        [orderMatrix setState:NSOnState atRow:0 column:0];
    else
        [orderMatrix setState:NSOnState atRow:0 column:1];

// hardware
    
    if ((portNameArray == nil) || (gotListing != YES))
        [portWarning setStringValue:@"Something wicked happened while listing your serial ports..."];
    else
        {
            [portCombo reloadData];
            [portWarning setStringValue:@""];
        }

    switch(options.lp.link_type)
        {
            case LINK_UGL:
                [linkTypeMatrix setState:NSOnState atRow:0 column:0];
                break;
            case LINK_TPU:
                [linkTypeMatrix setState:NSOnState atRow:0 column:1];
                break;
            case LINK_TIE:
                [linkTypeMatrix setState:NSOnState atRow:1 column:0];
                break;
            case LINK_VTI:
                [linkTypeMatrix setState:NSOnState atRow:1 column:1];
                break;
            case LINK_TGL:
                [linkTypeMatrix setState:NSOnState atRow:2 column:0];
                break;
            case LINK_SER:
                [linkTypeMatrix setState:NSOnState atRow:2 column:1];
                break;
            case LINK_NONE:
            case LINK_PAR:
            case LINK_AVR:
            case LINK_VTL:
            default:
                break;
        }

    if ((options.lp.link_type == LINK_TGL) || (options.lp.link_type == LINK_SER))
    {
        if ((portNameArray == nil) || (gotListing != YES))
        {
            [portWarning setStringValue:@"Something wicked happened while listing your serial ports..."];
        }
        else
        {
            portEnumerator = [portNameArray objectEnumerator];

            [portWarning setStringValue:@""];

            while ((portName = [portEnumerator nextObject]) != nil)
            {
                if ((options.lp.device != NULL)
                    && ([portName isEqualToString:[NSString stringWithCString:options.lp.device]]))
                {
                    [portCombo selectItemAtIndex:[portNameArray indexOfObject:portName]];
                    [portCombo setObjectValue:portName];

                    deviceMatched = YES;

                    break;
                }
            }
        }
    }
    
    if ((gotListing == YES) && (portNameArray != nil) && (deviceMatched == NO))
    {
        [portCombo selectItemAtIndex:0];
        [portCombo setObjectValue:[portNameArray objectAtIndex:0]];
    }
    
// calculator
    
    switch(ticalc_return_calc())
        {
            case CALC_V200:
                [calcTypeMatrix setState:NSOnState atRow:0 column:0];
                break;
            case CALC_TI92P:
                [calcTypeMatrix setState:NSOnState atRow:1 column:0];
                break;
            case CALC_TI92:
                [calcTypeMatrix setState:NSOnState atRow:2 column:0];
                break;
            case CALC_TI89:
                [calcTypeMatrix setState:NSOnState atRow:0 column:1];
                break;
            case CALC_TI86:
                [calcTypeMatrix setState:NSOnState atRow:1 column:1];
                break;
            case CALC_TI85:
                [calcTypeMatrix setState:NSOnState atRow:2 column:1];
                break;
            case CALC_TI83P:
                [calcTypeMatrix setState:NSOnState atRow:0 column:2];
                break;
            case CALC_TI83:
                [calcTypeMatrix setState:NSOnState atRow:1 column:2];
                break;
            case CALC_TI82:
                [calcTypeMatrix setState:NSOnState atRow:2 column:2];
                break;
            case CALC_TI73:
                [calcTypeMatrix setState:NSOnState atRow:0 column:3];
                break;
        }
                
    if (options.auto_detect == TRUE)
        [calcTypeProbe setState:NSOnState];
    else
        [calcTypeProbe setState:NSOffState];

// screendump
    
    switch(options.screen_format)
        {
            case TIFF:
                [screenFormatMatrix setState:NSOnState atRow:0 column:0];
                break;
            case PDF:
                [screenFormatMatrix setState:NSOnState atRow:0 column:1];
                break;
        }

    if (options.screen_blurry == FALSE)
        [screenRenderingMatrix setState:NSOnState atRow:0 column:0];
    else
        [screenRenderingMatrix setState:NSOnState atRow:0 column:1];
        
    if (options.screen_clipping == FULL_SCREEN)
        [screenModeMatrix setState:NSOnState atRow:0 column:0];
    else
        [screenModeMatrix setState:NSOnState atRow:0 column:1];

    switch(options.screen_scaling)
    {
        case 2:
            [screenScaleMatrix setState:NSOnState atRow:0 column:1];
            break;
        case 3:
            [screenScaleMatrix setState:NSOnState atRow:1 column:0];
            break;
        case 4:
            [screenScaleMatrix setState:NSOnState atRow:1 column:1];
            break;
        default:
            [screenScaleMatrix setState:NSOnState atRow:0 column:0];
            break;
    }

// clock

    if (options.clock_mode == CLOCK_SYNC)
        [clockModeMatrix setState:NSOnState atRow:0 column:0];
    else
        [clockModeMatrix setState:NSOnState atRow:0 column:1];

    if (options.time_format == 12)
        [clockTimeFormatMatrix setState:NSOnState atRow:0 column:0];
    else
        [clockTimeFormatMatrix setState:NSOnState atRow:0 column:1];

    [clockDateFormat selectItemAtIndex:(options.date_format - 1)];

// advanced

    if ((options.lp.timeout > 0) && (options.lp.timeout <= 50))
        [linkTimeoutField setIntValue:options.lp.timeout];
    else // defaults to 5 (tenth of seconds -- half a second)
        [linkTimeoutField setIntValue:5];
        
    if (options.console_mode == DSP_ON)
        [consoleModeMatrix setState:NSOnState atRow:0 column:0];
    else
        [consoleModeMatrix setState:NSOnState atRow:0 column:1];
        
    [NSApp beginSheet:prefsWindow
           modalForWindow:[myBoxesController keyWindow]
           modalDelegate:nil
           didEndSelector:nil
           contextInfo:nil];
           
    [NSApp runModalForWindow:prefsWindow];
    
    [NSApp endSheet:prefsWindow];
    [prefsWindow orderOut:self];
}

- (BOOL)getSerialPortsList
{
    mach_port_t			masterPort;
    kern_return_t 		kr = KERN_FAILURE;
    io_object_t 		serialService;
    io_iterator_t 		serialIterator;
    
    CFTypeRef			portNameAsCFString;
    CFTypeRef			bsdPathAsCFString;
    CFMutableDictionaryRef 	classesToMatch;

    char portName[128];
    char bsdPath[MAXPATHLEN];

    Boolean result;
    
#ifdef OSX_DEBUG
    fprintf(stderr, "DEBUG: getting serial ports listing...\n");
#endif

    kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
        
    if (KERN_SUCCESS != kr)
        {
#ifdef OSX_DEBUG
            fprintf(stderr, "IOMasterPort returned %d\n", kr);
#endif
            return NO;
        }

    // Serial devices are instances of class IOSerialBSDClient
    classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    
    if (classesToMatch != NULL)
        {
            CFDictionarySetValue(classesToMatch,
                                CFSTR(kIOSerialBSDTypeKey),
                                CFSTR(kIOSerialBSDAllTypes)); // all serial...
        }
#ifdef OSX_DEBUG
    else
        fprintf(stderr, "IOServiceMatching returned a NULL dictionary.\n");
#endif
    
    kr = IOServiceGetMatchingServices(masterPort, classesToMatch, &serialIterator);    
    
    if (KERN_SUCCESS != kr)
        {
#ifdef OSX_DEBUG
            fprintf(stderr, "IOServiceGetMatchingServices returned %d\n", kr);
#endif
            return NO;
        }
        
    if (portNameArray != nil)
        [portNameArray release];
        
    portNameArray = [[NSMutableArray alloc] init];
    [portNameArray retain];
        
    if (portTypeArray != nil)
        [portTypeArray release];
        
    portTypeArray = [[NSMutableArray alloc] init];
    [portTypeArray retain];
        
    while ((serialService = IOIteratorNext(serialIterator)))
        {
            bsdPathAsCFString = IORegistryEntryCreateCFProperty(serialService,
                                                                CFSTR(kIOCalloutDeviceKey),
                                                                kCFAllocatorDefault,
                                                                0);
            if (bsdPathAsCFString)
                {
                    result = CFStringGetCString(bsdPathAsCFString,
                                                bsdPath,
                                                sizeof(bsdPath), 
                                                kCFStringEncodingASCII);
                    CFRelease(bsdPathAsCFString);
            
                    if (result)
                        {
#ifdef OSX_DEBUG
                            fprintf(stderr, "BSD path: %s, ", bsdPath);
#endif                            
                            [portNameArray addObject:[NSString stringWithCString:bsdPath]];
                        }
                }


            portNameAsCFString = IORegistryEntryCreateCFProperty(serialService,
                                                                CFSTR(kIOTTYDeviceKey),
                                                                kCFAllocatorDefault,
                                                                0);
            if (portNameAsCFString)
                {
                    result = CFStringGetCString(portNameAsCFString,
                                                portName,
                                                sizeof(portName), 
                                                kCFStringEncodingASCII);
                    CFRelease(portNameAsCFString);
            
                    if (result)
                        {
#ifdef OSX_DEBUG
                            fprintf(stderr, "Serial stream name: %s", portName);
#endif
                            [portTypeArray addObject:[NSString stringWithFormat:@"Type : %s", portName]];
                            
                            kr = KERN_SUCCESS;
                        }
                }
#ifdef OSX_DEBUG
            fprintf(stderr, "\n");
#endif
            IOObjectRelease(serialService);
        }

    IOObjectRelease(serialIterator);

#ifdef OSX_DEBUG
    fprintf(stderr, "DEBUG: got listing...\n");
#endif

    return (kr == KERN_SUCCESS) ? YES : NO;
}

// NSComboBox datasource
- (id)comboBox:(NSComboBox *)combo objectValueForItemAtIndex:(int)index
{
#ifdef OSX_DEBUG
    fprintf(stderr, "DEBUG: asking object value\n");
#endif

    if (portNameArray != nil)
        return [portNameArray objectAtIndex:index];
    else
        return nil;
}
- (int)numberOfItemsInComboBox:(NSComboBox *)combo;
{
#ifdef OSX_DEBUG
    fprintf(stderr, "DEBUG: asking number of elements\n");
#endif

    if (portNameArray != nil)
        return [portNameArray count];
    else
        return 0;
}

// NSComboBox delegate
- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSString *type;

#ifdef OSX_DEBUG
    fprintf(stderr, "DEBUG: SELECTION CHANGED\n");
#endif

    type = [portTypeArray objectAtIndex:[portCombo indexOfSelectedItem]];
    
    [portType setStringValue:type];
}

@end