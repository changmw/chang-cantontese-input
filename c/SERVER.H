struct Connection_ID_Rec {
	unsigned char	in_use_flag;
	unsigned char	server_order;
	unsigned char	network_address[4];
	unsigned char	server_address[6];
	unsigned char	socket_number[2];
	unsigned char	receive_timeout[2];
	unsigned char	routing_address[6];
	unsigned char	packet_sequence;
	unsigned char	connection_no;
	unsigned char	connection_status;
	unsigned char	max_timeout[2];
	unsigned char	filler[5];
} ID_table[8];

struct Server_Name_Rec {
	char		server_name[48];
} server_table[8];

