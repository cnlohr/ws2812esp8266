#include "mem.h"
#include "c_types.h"
#include "user_interface.h"
#include "ets_sys.h"
#include "driver/uart.h"
#include "osapi.h"
#include "espconn.h"
#include "mystuff.h"

#define PORT 7777
#define SERVER_TIMEOUT 1000
#define MAX_CONNS 5

#define at_procTaskPrio        0
#define at_procTaskQueueLen    1


static struct espconn *pUdpServer;











os_event_t    at_procTaskQueue[at_procTaskQueueLen];

static void at_procTask(os_event_t *events);

static void ICACHE_FLASH_ATTR
at_procTask(os_event_t *events)
{
//	uart0_sendStr("ATPRoc");
	system_os_post(at_procTaskPrio, 0, 0 );
	if( events->sig == 0 && events->par == 0 )
	{
		//Idle Event.
/*		if( connections[0].pespconn && connections[0].cansend )
		{
		    espconn_sent( connections[0].pespconn, "hello\r\n", 7 );
		}
*/
	}
}


static void ICACHE_FLASH_ATTR
at_udpserver_recv(void *arg, char *pusrdata, unsigned short len)
{
	struct espconn *pespconn = (struct espconn *)arg;
	WS2812OutBuffer( pusrdata, len );
	uart0_sendStr("sent\r\n");
	return;
}


void at_recvTask()
{
	//Start popping stuff off fifo. (UART)
}

void user_init(void)
{
	uart_init(BIT_RATE_115200, BIT_RATE_115200);
	int at_wifiMode = wifi_get_opmode();

	uart0_sendStr("\r\nCustom Server\r\n");

	wifi_set_opmode( 2 ); //We broadcast our ESSID, wait for peopel to join.

    pUdpServer = (struct espconn *)os_zalloc(sizeof(struct espconn));
    if (pUdpServer == NULL)
    {
      uart0_sendStr("UdpServer Failure\r\n");
      return;
    }
    pUdpServer->type = ESPCONN_UDP;
    pUdpServer->state = ESPCONN_NONE;
    pUdpServer->proto.udp = (esp_udp *)os_zalloc(sizeof(esp_udp));
    pUdpServer->proto.udp->local_port = PORT;
    pUdpServer->reverse = NULL;
    espconn_regist_recvcb(pUdpServer, at_udpserver_recv);
    espconn_accept(pUdpServer);


	char outbuffer[] = { 0xff, 0x00, 0x00, 0x00, 0xff, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff };
	WS2812OutBuffer( outbuffer, sizeof(outbuffer) );

	system_os_task(at_procTask, at_procTaskPrio, at_procTaskQueue, at_procTaskQueueLen);

	uart0_sendStr("\r\nCustom Server\r\n");
	system_os_post(at_procTaskPrio, 0, 0 );
}
