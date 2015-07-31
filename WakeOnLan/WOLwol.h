//
//  WOLwol.h
//  WakeOnLan
//
//  Created by Clément Padovani on 7/31/15.
//  Copyright © 2015 Clément Padovani. All rights reserved.
//

#ifndef WOLwol_h
#define WOLwol_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

int host2addr(char *name, struct in_addr *addrp, unsigned char *familyp);

int hex(unsigned char c);

int hex2(unsigned char *p);

int send_wol_packet(unsigned char *broadcast_addr, unsigned char *mac_addr);

#endif /* WOLwol_h */
