/*
 *  IPX.H -- see 'ipx.c'.
 *
*/

#define ipx_sk_already_open   0xFF
#define ipx_sk_table_full     0xFE

#define ipx_sd_event_cancelled  0xFC
#define ipx_sd_bad_packet       0xFD
#define ipx_sd_undeliverable    0xFE
#define ipx_sd_network_failure  0xFF

#define ipx_rv_event_cancelled  0xFC
#define ipx_rv_buf_too_small    0xFD
#define ipx_rv_socket_not_open  0xFF


struct IPXHEADER
    {
    unsigned int    checksum;
    unsigned int    length;
    unsigned char   transport_control;
    unsigned char   packet_type;
    unsigned char   dest_network_number [4];
    unsigned char   dest_network_node   [6];
    unsigned int    dest_network_socket;
    unsigned char   source_network_number [4];
    unsigned char   source_network_node   [6];
    unsigned int    source_network_socket;
    };

struct ECB
    {
    void far        *link_address;
    void far        (*event_service_routine)(void);
    unsigned char   in_use;
    unsigned char   completion_code;
    unsigned int    socket_number;
    unsigned int    connection_id;      /* returned by Listen */
    unsigned int    rest_of_workspace;
    unsigned char   driver_workspace  [12];
    unsigned char   immediate_address [ 6];
    unsigned int    packet_count;
    struct {
        void far    *address;
        unsigned int length;
        } packet [2];
    };


int      ipx_spx_installed(void);
int      ipx_cancel_event(struct ECB *ecb_ptr);
void     close_socket(unsigned int socket);
int      open_socket(unsigned int socket);
int      get_local_target(unsigned char *dest_network,
                         unsigned char *dest_node,
                         unsigned int   dest_socket,
                         unsigned char *bridge_address);
void     let_ipx_breath(void);
void     ipx_listen_for_packet(struct ECB *ecb_ptr);
void     ipx_send_packet(struct ECB *ecb_ptr);
int      get_internet_address(unsigned char connection_number,
                            unsigned char *network_number,
                            unsigned char *physical_node);
unsigned int    get_1st_connection_num (char *who);
unsigned char get_connection_number(void);
void     get_user_id(unsigned char connection_number,
                    unsigned char *user_id);
void     ipx_relinquish_control(void);

void far          (*ipx_spx)(void);

int     ipx_spx_installed(void)
        {
        union REGS      regs;
        struct SREGS    sregs;

        regs.x.ax = 0x7a00;
        int86x(0x2f, &regs, &regs, &sregs);
        if (regs.h.al != 0xff) return -1;

        ipx_spx = MK_FP(sregs.es, regs.x.di);
        _BX = 0x0010;
        _AL = 0x00;
        ipx_spx();
        if (_AL == 0x00) return 0;

        return 1;
        }

int     ipx_cancel_event(struct ECB *ecb_ptr)
        {
        _ES = FP_SEG( (void far *) ecb_ptr);
        _SI = FP_OFF( (void far *) ecb_ptr);
        _BX = 0x0006;
        ipx_spx();
        _AH = 0;
        return _AX;
        }

void    close_socket(unsigned int socket)
        {
        if (ipx_spx_installed() < 1) return;
        _BX = 0x0001;
        _DX = socket;
        ipx_spx();
        }

int     open_socket(unsigned int socket)
        {
        if (ipx_spx_installed() < 1) return -1;
        _DX = socket;
        _BX = 0x0000;
        _AL = 0xFF;
        ipx_spx();
        _AH = 0;
        return _AX;
        }

int     get_local_target(unsigned char *dest_network,
                         unsigned char *dest_node,
                         unsigned int   dest_socket,
                         unsigned char *bridge_address)
        {
        unsigned int    temp_ax;

        struct  {
                unsigned char   network_number [4];
                unsigned char   physical_node  [6];
                unsigned int    socket;
                } request_buffer;

        struct  {
                unsigned char   local_target [6];
                } reply_buffer;

        memcpy(request_buffer.network_number, dest_network, 4);
        memcpy(request_buffer.physical_node, dest_node, 6);
        request_buffer.socket = dest_socket;

        _ES = FP_SEG( (void far *) &request_buffer);
        _SI = FP_OFF( (void far *) &request_buffer);
        _DI = FP_OFF( (void far *) &reply_buffer);
        _BX = 0x0002;
        ipx_spx();
        _AH = 0;
        temp_ax = _AX;
        memcpy(bridge_address, reply_buffer.local_target, 6);
        return temp_ax;
        }

void    let_ipx_breath(void)
        {
        _BX = 0x000A;
        ipx_spx();
        }

void    ipx_listen_for_packet(struct ECB *ecb_ptr)
        {
        _ES = FP_SEG( (void far *) ecb_ptr);
        _SI = FP_OFF( (void far *) ecb_ptr);
        _BX = 0x0004;
        ipx_spx();
        }

void    ipx_send_packet(struct ECB *ecb_ptr)
        {
        _ES = FP_SEG( (void far *) ecb_ptr);
        _SI = FP_OFF( (void far *) ecb_ptr);
        _BX = 0x0003;
        ipx_spx();
        }

int     get_internet_address(unsigned char connection_number,
                            unsigned char *network_number,
                            unsigned char *physical_node)
        {
        union REGS      regs;
        struct SREGS    sregs;

        struct  {
                unsigned int    len;
                unsigned char   buffer_type;
                unsigned char   connection_number;
                } request_buffer;

        struct  {
                unsigned int    len;
                unsigned char   network_number [4];
                unsigned char   physical_node  [6];
                unsigned int    server_socket;
                } reply_buffer;

        regs.h.ah = 0xe3;
        request_buffer.len = 2;
        request_buffer.buffer_type = 0x13;
        request_buffer.connection_number = connection_number;

        reply_buffer.len = 12;

        regs.x.si = FP_OFF( (void far *) &request_buffer);
        sregs.ds  = FP_SEG( (void far *) &request_buffer);
        regs.x.di = FP_OFF( (void far *) &reply_buffer);
        sregs.es  = FP_SEG( (void far *) &reply_buffer);
        int86x(0x21, &regs, &regs, &sregs);

        memcpy(network_number, reply_buffer.network_number, 4);
        memcpy(physical_node,  reply_buffer.physical_node,  6);
        regs.h.ah = 0;
        return regs.x.ax;
        }

unsigned int    get_1st_connection_num (char *who)
        {
        union REGS      regs;
        struct SREGS    sregs;

        struct  {
                unsigned int    len;
                unsigned char   buffer_type;
                unsigned int    object_type;
                unsigned char   name_len;
                unsigned char   name [47];
                } request_buffer;

        struct  {
                unsigned int    len;
                unsigned char   number_connections;
                unsigned char   connection_num [100];
                } reply_buffer;

        regs.h.ah = 0xe3;

        request_buffer.len = 51;
        request_buffer.buffer_type = 0x15;
        request_buffer.object_type = 0x0100;
        request_buffer.name_len    = (unsigned char) strlen(who);
        strcpy(request_buffer.name, who);

        reply_buffer.len = 101;

        regs.x.si = FP_OFF( (void far *) &request_buffer);
        sregs.ds  = FP_SEG( (void far *) &request_buffer);
        regs.x.di = FP_OFF( (void far *) &reply_buffer);
        sregs.es  = FP_SEG( (void far *) &reply_buffer);

        int86x(0x21, &regs, &regs, &sregs);

        if (regs.h.al != 0) return 0;
        if (reply_buffer.number_connections == 0) return 0;

        regs.h.ah = 0;
        regs.h.al = reply_buffer.connection_num[0];
        return regs.x.ax;
        }

unsigned char get_connection_number(void)
        {
        _AH = 0xDC;
        geninterrupt(0x21);
        return _AL;
        }

void    get_user_id(unsigned char connection_number,
                    unsigned char *user_id)
        {
        union REGS      regs;
        struct SREGS    sregs;

        struct  {
                unsigned int    len;
                unsigned char   buffer_type;
                unsigned char   connection_number;
                } request_buffer;

        struct  {
                unsigned int    len;
                unsigned char   object_id[4];
                unsigned char   object_type[2];
                char            object_name[48];
                char            login_time[7];
                } reply_buffer;

        regs.h.ah = 0xe3;
        request_buffer.len = 2;
        request_buffer.buffer_type = 0x16;
        request_buffer.connection_number = connection_number;

        reply_buffer.len = 61;

        regs.x.si = FP_OFF( (void far *) &request_buffer);
        sregs.ds  = FP_SEG( (void far *) &request_buffer);
        regs.x.di = FP_OFF( (void far *) &reply_buffer);
        sregs.es  = FP_SEG( (void far *) &reply_buffer);
        int86x(0x21, &regs, &regs, &sregs);

        strncpy(user_id, reply_buffer.object_name, 48);
        }

void ipx_relinquish_control(void) {
  _BX = 0x000A;
  ipx_spx();
}
