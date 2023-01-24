/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/Behdad/Desktop/tt/tt/ipcore_dir/DCM_40_40MHz.vhd";



static void work_a_0450625810_0912031422_p_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;

LAB0:    xsi_set_current_line(156, ng0);

LAB3:    t1 = (t0 + 4656);
    t2 = (t1 + 56U);
    t3 = *((char **)t2);
    t4 = (t3 + 56U);
    t5 = *((char **)t4);
    *((unsigned char *)t5) = (unsigned char)2;
    xsi_driver_first_trans_fast(t1);

LAB2:
LAB1:    return;
LAB4:    goto LAB2;

}


extern void work_a_0450625810_0912031422_init()
{
	static char *pe[] = {(void *)work_a_0450625810_0912031422_p_0};
	xsi_register_didat("work_a_0450625810_0912031422", "isim/TB_isim_beh.exe.sim/work/a_0450625810_0912031422.didat");
	xsi_register_executes(pe);
}
