

volatile int debug_spi __attribute__((section(".debug_spi")));

static int golden_truth[] = {0xDEADBEEF, 0xABBAABCD, 0x01234567, 0x1, 0x2, 0x3, 0x4};

int errors = 0;

void main(){

    for (int i = 0 ; i < 5000 ; i++) { asm volatile ("nop"); }

    for( int i = 0; i < sizeof(golden_truth)/4; i++){
        int read = ((int*)(&debug_spi))[i];
        int golden = golden_truth[i];
        if (read == golden){
            printf("%08X ✔\n", read);
        } else{
            printf("%08X ❌ (%d)\n", read, &(((int*)(&debug_spi))[i]));
            errors++;
        }
    }

    if(errors){
        printf(":( %d/%d errors\n", errors, sizeof(golden_truth)/4);
        return 1;
    } else{
        printf("=) ALL GOOD\n");
        return 0;
    }


}