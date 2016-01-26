LIBRARY IEEE;
LIBRARY WORK;

USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY draw_octant IS
  PORT(
    clk, init, draw, xbias, disable		: IN  std_logic;
    xin, yin									: IN  std_logic_vector(11 DOWNTO 0);
    done											: OUT std_logic;
    x, y											: OUT std_logic_vector(11 DOWNTO 0)
    );
END ENTITY draw_octant;

ARCHITECTURE behav OF draw_octant IS

  SIGNAL done1								: std_logic;
  SIGNAL x1, y1							: std_logic_vector(11 DOWNTO 0);
  SIGNAL xincr, yincr, xnew, ynew	: std_logic_vector(11 DOWNTO 0);
  SIGNAL error, err1, err2				: std_logic_vector(12 DOWNTO 0);

  ALIAS slv IS std_logic_vector;

BEGIN

	C1 : PROCESS(error, xincr, yincr, x1, y1, xnew, ynew, init, draw)
		VARIABLE err1_v, err2_v : std_logic_vector(12 DOWNTO 0);
 
		BEGIN
			-- Use of inbuilt function abs, assume synthesizable 
			err1 <= slv(abs(signed(error) + signed(yincr)));
			err2 <= slv(abs(signed(error) + signed(yincr) - signed(xincr)));
			
			-- done is a number of comparisons, collected together by AND gates 
			done1 <= '0';
			IF 	x1 = xnew 	AND
					y1 = ynew 	AND
					init = '0' 	AND
					draw = '0' 	THEN
				done1 <= '1';
			END IF; --done1
		
		END PROCESS C1;

	R1 : PROCESS(disable, err1, err2, xbias, init, draw, done1, xin, yin, x1, y1, error, xincr, yincr) -- Added xin, yin, x1, y1, error as they are missing from sensitivity list
		BEGIN
			-- Only assign outputs if disable is low
			IF disable='0' THEN
				-- If initialising, assign outputs as follows
				IF init = '1' THEN
					-- Assign x, y values
					x1 <= xin;
					y1 <= yin;
					xnew <= xin;
					ynew <= yin;
					-- Assign increment values
					xincr <= "000000000000";
					yincr <= "000000000000";
					
				-- else check other parameters
				ELSE
					IF draw = '1' THEN
						xincr <= slv(signed(xin) - signed(x1));
						yincr <= slv(signed(yin) - signed(y1));
						xnew <= xin;
						ynew <= yin;
					ELSE
						-- Check to see if done
						IF done1 = '0' THEN
						
							IF err1 > err2 OR (err1 = err2 AND xbias = '0') THEN
								error <= slv(signed(error) + signed(yincr) - signed(xincr));
								x1 <= slv(signed(x1) + 1);
								y1 <= slv(signed(y1) + 1);
							ELSIF err1 < err2 OR (err1 = err2 AND xbias = '1') THEN
								error <= slv(signed(error) + signed(yincr));
								x1 <= slv(signed(x1) + 1);
							END IF;
						
						-- No else, as outputs are not changed if done is 1
						END IF; --done1
					END IF; --draw
				END IF; --init
			END IF; --disable
  
		END PROCESS R1;
		
		-- Assign to signals to output ports
		x <= x1;
		y <= y1;
		done <= done1;

END ARCHITECTURE behav;
