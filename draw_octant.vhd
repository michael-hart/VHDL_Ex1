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
  
			-- Only assign outputs if disable is low
			IF disable = '0' AND done = '0' THEN
				-- If initialising, assign outputs as follows
				IF init = '1' THEN
					-- Assign x, y values
					x <= xin;
					y <= yin;
					xnew <= xin;
					ynew <= yin;
					-- Assign increment values
					xincr <= '0';
					yincr <= '0';
					
				-- else check other parameters
				ELSE
					IF draw = '1' THEN
						xincr <= slv(signed(xin) - signed(x));
						yincr <= slv(signed(yin) - signed(y));
						xnew <= xin;
						ynew <= yin;
					ELSE
						-- Check to see if done
						IF done = '0' THEN
						
							IF err1 > err2 THEN
								error <= slv(signed(error) + signed(yincr) - signed(xincr));
								x <= slv(signed(x) + 1);
								y <= slv(signed(y) + 1);
							ELSIF err1 < err2 THEN
								error <= slv(signed(error) + signed(yincr));
								x <= slv(signed(x) + 1);
							ELSE
								-- Check xbias
								IF xbias = '1' THEN
									error <= slv(signed(error) + signed(yincr));
									x <= slv(signed(x) + 1);
								ELSE
									error <= slv(signed(error) + signed(yincr) - signed(xincr));
									x <= slv(signed(x) + 1);
									y <= slv(signed(y) + 1);
								END IF xbias;
							
							END IF err1err2;
						
						-- No else, as outputs are not changed if done is 1
						END IF done;
					END IF draw;
				END IF init;
			END IF disable;
		END PROCESS R1;

END ARCHITECTURE behav;
