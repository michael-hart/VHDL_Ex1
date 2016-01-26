LIBRARY IEEE;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY draw_octant IS
  PORT(
    clk, init, draw, xbias,disable   : IN  std_logic;
    xin, yin                 		 : IN  std_logic_vector(11 DOWNTO 0);
    done                       	     : OUT std_logic;
    x, y                  		     : OUT std_logic_vector(11 DOWNTO 0)
    );
END ENTITY draw_octant;

ARCHITECTURE behav OF draw_octant IS

  SIGNAL done1                    : std_logic;
  SIGNAL x1, y1                   : std_logic_vector(11 DOWNTO 0);
  SIGNAL xincr, yincr, xnew, ynew : std_logic_vector(11 DOWNTO 0);
  SIGNAL error, err1, err2        : std_logic_vector(12 DOWNTO 0);

  ALIAS slv IS std_logic_vector;

BEGIN

	C1 : PROCESS(error, xincr, yincr, x1, y1, xnew, ynew, init, draw)
		VARIABLE err1_v, err2_v : std_logic_vector(12 DOWNTO 0);
 
		BEGIN
			-- Use of inbuilt function abs, assume synthesizable 
			err1 <= slv(abs(signed(error) + signed(yincr)));
			err2 <= slv(abs(signed(error) + signed(yincr) - signed(xincr)));
			
			-- done is a number of comparisons, collected together by AND gates 
			done <=	x = xnew 	AND
						y = ynew 	AND
						init = '0' 	AND
						draw = '0'	;
		
		END PROCESS C1;

  R1 : PROCESS(disable, err1, err2, xbias, init, draw, done)
  BEGIN
  
  END PROCESS R1;

END ARCHITECTURE behav;

