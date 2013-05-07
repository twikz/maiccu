//
//  aiccu_main.h
//  maiccu
//
//  Created by Kristof Hannemann on 04.05.13.
//  Copyright (c) 2013 Kristof Hannemann. All rights reserved.
//

#ifndef maiccu_aiccu_main_h
#define maiccu_aiccu_main_h

void sigusr1(int i);
void sigterm(int i);
int sigrunning(int sig);
int list_tunnels(void);
void gotrr(unsigned int num, int type, const char *record);
int list_brokers(void);
struct TIC_Tunnel *get_tunnel(void);


#endif
