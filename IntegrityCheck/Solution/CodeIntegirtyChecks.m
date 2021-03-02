//
//  CodeIntegirtyChecks
//
//  Created by Christos Koninis on 1/21/21.
//

#include <CommonCrypto/CommonCrypto.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>

@import UIKit;

// This is a placeholder value, that the build phase script will search for this value and replace it
// after the build with the actual sha512 of the application code (The assemply code only __text section)
const char * const originalDigestAsHex = "b49f106b516fcd8a87258b23939586a7974cd7350dd4fe3c3699a1f6b7781cb5b68db30c7625284174d96bbb1586d73c8229596c16e584013d05e844d9464df5";

static inline int __attribute__((always_inline)) validate_code_hash(const void *srcBuffer, uint64_t len)
{
    unsigned char digest[CC_SHA512_DIGEST_LENGTH];
    char digestAsHexString[2 * CC_SHA512_DIGEST_LENGTH];            // will hold the signature

    CC_SHA512(srcBuffer, (CC_LONG)len, digest);     // calculate the signature 32121960 92000 -

    for (int i = 0; i < sizeof(digest); i++)             // fill signature
        sprintf(digestAsHexString + (2 * i), "%02x", digest[i]);

    return strncmp(digestAsHexString, originalDigestAsHex, 2 * CC_SHA512_DIGEST_LENGTH);
}

void correctCheckSumForTextSection()
{
    size_t segmentOffset = sizeof(struct mach_header_64);
    Dl_info dlinfo;

    if (dladdr(validate_code_hash, &dlinfo) == 0 || dlinfo.dli_fbase == NULL)
        return; // Can't find symbol for validate_code_hash

    const struct mach_header_64 * machHeader;
    machHeader = dlinfo.dli_fbase;  // Pointer on the Mach-O header


    // For each load command of the mach-o file
    for (uint32_t i = 0; i < machHeader->ncmds; i++) {

        struct load_command *loadCommand = (struct load_command *)((uint8_t *) machHeader + segmentOffset);
        if(loadCommand->cmd == LC_SEGMENT_64) {
            struct segment_command_64 *segCommand = (struct segment_command_64 *) loadCommand;

            void *sectionPtr = (void *)(segCommand + 1);
            for (uint32_t nsect = 0; nsect < segCommand->nsects; ++nsect) {
                struct section_64 *section = (struct section_64 *)sectionPtr;

                if (strncmp(segCommand->segname, SEG_TEXT, 16) == 0) {
                    if (strncmp(section->sectname, SECT_TEXT, 16) == 0) {
                        if(validate_code_hash((uint8_t *) machHeader + section->offset, section->size)!=0) {
                            // checksum validation failed!
                            NSLog(@"Code integrity check failed!!!");
                            abort();
                        }
                    }
                }

                sectionPtr += sizeof(struct section_64);
            }
        }

        segmentOffset += loadCommand->cmdsize;
    }
}

///  In order to avoid the digest beeing removed by dead code elimination from the compiler optimizations  it must appear to be used
NSString * aMethod()
{
    return [NSString stringWithCString:originalDigestAsHex encoding:NSASCIIStringEncoding];
}
