��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qX?   /home/lgpu0444/diagnostics-shapes/baseline/models/shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XJ   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   63754880q7X   cuda:0q8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   65876832qCX   cuda:0qDKNtqEQK K�qFK�qG�h)RqHtqIRqJ�h)RqK�qLRqMuhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqShh)RqTX   trainingqU�X   in_channelsqVKX   out_channelsqWKX   kernel_sizeqXKK�qYX   strideqZKK�q[X   paddingq\K K �q]X   dilationq^KK�q_X
   transposedq`�X   output_paddingqaK K �qbX   groupsqcKubX   1qd(h ctorch.nn.modules.batchnorm
BatchNorm2d
qeXO   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/batchnorm.pyqfX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qgtqhQ)�qi}qj(hh	h
h)Rqk(h2h3h4((h5h6X   64153440qlX   cuda:0qmKNtqnQK K�qoK�qp�h)RqqtqrRqs�h)Rqt�quRqvhBh3h4((h5h6X   64153536qwX   cuda:0qxKNtqyQK K�qzK�q{�h)Rq|tq}Rq~�h)Rq�q�Rq�uhh)Rq�(X   running_meanq�h4((h5h6X   64597216q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   64565296q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   64621088q�X   cuda:0q�KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XP   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   64539488q�X   cuda:0q�MNtq�QK (KKKKtq�(K�K	KKtqh)Rq�tq�Rqňh)RqƇq�Rq�hBh3h4((h5h6X   64526272q�X   cuda:0q�KNtq�QK K�q�K�q͉h)Rq�tq�RqЈh)Rqчq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hU�hVKhWKhXKK�q�hZKK�q�h\K K �q�h^KK�q�h`�haK K �q�hcKubX   4q�he)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   64551264q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   64539584q�X   cuda:0q�KNtq�QK K�q�K�q�h)Rq�tq�Rq��h)Rq��q�Rq�uhh)Rq�(h�h4((h5h6X   64620272q�X   cuda:0q�KNtq�QK K�q�K�q��h)Rr   tr  Rr  h�h4((h5h6X   64251664r  X   cuda:0r  KNtr  QK K�r  K�r  �h)Rr  tr	  Rr
  h�h4((h5h�X   63010624r  X   cuda:0r  KNtr  QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   5r  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr   hh)Rr!  hU�h�G        h�G        h��ubX   6r"  h+)�r#  }r$  (hh	h
h)Rr%  (h2h3h4((h5h6X   64601904r&  X   cuda:0r'  MNtr(  QK (KKKKtr)  (K�K	KKtr*  �h)Rr+  tr,  Rr-  �h)Rr.  �r/  Rr0  hBh3h4((h5h6X   64966624r1  X   cuda:0r2  KNtr3  QK K�r4  K�r5  �h)Rr6  tr7  Rr8  �h)Rr9  �r:  Rr;  uhh)Rr<  hh)Rr=  hh)Rr>  hh)Rr?  hh)Rr@  hh)RrA  hh)RrB  hU�hVKhWKhXKK�rC  hZKK�rD  h\K K �rE  h^KK�rF  h`�haK K �rG  hcKubX   7rH  he)�rI  }rJ  (hh	h
h)RrK  (h2h3h4((h5h6X   64419648rL  X   cuda:0rM  KNtrN  QK K�rO  K�rP  �h)RrQ  trR  RrS  �h)RrT  �rU  RrV  hBh3h4((h5h6X   64818080rW  X   cuda:0rX  KNtrY  QK K�rZ  K�r[  �h)Rr\  tr]  Rr^  �h)Rr_  �r`  Rra  uhh)Rrb  (h�h4((h5h6X   65379456rc  X   cuda:0rd  KNtre  QK K�rf  K�rg  �h)Rrh  tri  Rrj  h�h4((h5h6X   53974752rk  X   cuda:0rl  KNtrm  QK K�rn  K�ro  �h)Rrp  trq  Rrr  h�h4((h5h�X   64933600rs  X   cuda:0rt  KNtru  QK ))�h)Rrv  trw  Rrx  uhh)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hU�h�Kh�G>�����h�h�G?�������h��h��ubX   8r  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubX   linr�  h)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XL   /home/lgpu0444/.local/lib/python3.6/site-packages/torch/nn/modules/linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   65842640r�  X   cuda:0r�  M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   65842736r�  X   cuda:0r�  K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hU�h�G        h�G        h��ubuhU�ubuhU�ub.�]q (X   53974752qX   63010624qX   63754880qX   64153440qX   64153536qX   64251664qX   64419648qX   64526272qX   64539488q	X   64539584q
X   64551264qX   64565296qX   64597216qX   64601904qX   64620272qX   64621088qX   64818080qX   64933600qX   64966624qX   65379456qX   65842640qX   65842736qX   65876832qe.       ��5?�X�>��&?��?�P?��?%��>�5�?��>���>F�>˒�>��	?���>!��>�%�>o��>ڢ?��E?�t�>       �G            Z��t6��ì�??M=YG��JA=1ā=�پ��*>k�j�	��=U�����>���=/n�</j^=��{�ϩ��C=�~ڽ��O>�Ņ���">Ȥ����`�M>��=v!��r��y׃<�XQ�V��:�>Yt>>>�;��潙��;�1��>�6�����?�3�F>sO>��<MY����4��<
HJ�i���F5�<9\>�#>~��=�����/å=�@Ǽ�ㆾ �����c=ZQ=��<�@��r���i� ��U`��y搻��۽/<F<�B�/�I>�}^�M_&>�����R�1��'�~>{Y��@�93��=�?<I氽�䠽T���훼�$>���={�9�]�2�#�D�����h�<�:��Y��<�_>Y=��:�G�=�[s�L^���t">�D��$ﾽ.��=km�>I >O�"�M�=7�z=�:�����lH��x[�m�=��Z��<>�]�=&&�=^�=l�G��=�(=:�8����=?���l6����~<+��=8��D�m�/D��<���s�m��=���h
�䥟�!��=��>�X��c��=��Y�J������w*<�yֽ!e>��o=�7��&=v�$>	>z���m�C��!p��֤=)0=���=/��=Y����eT�b�<�Ü��l*=7��=�>3�ҽ�v���>t>������z~���<3�3=�5�=1�a<�\"��>b�>�^����.���:�(V.={_!��h�<{^>棕�%*�M�-=��:�ݒ�)'�=�?��&]���~��i��=�ۜ��Q��l8q�eV��=o֦=јT>���={�%>C:�=�@�_R���,�=��i=�a���'>����\�O>�L�<��u=�z�=4%�<������=�㳽���A�T��Ez<��?>Ȑ��B�/Bн�O���ֽ\�=�n���s>�UA�iai�����U���J�=!��;�>n�ٽR7�=GU�F�<������"��%7=�j!>j����_t�I9>?��Q��Q�<8%6�Z����&`�Ȧ'>r�`���=|9��򼽞������<'�=�y�=ܱk=y�D- =��=�����	�w�W�G�3�w�;>.U/>ީ+=��V=.=<�=�Ox<bw�Č�G�`;|��b-���W�I�q� �1�Q�f>�Y>��0�w��\�>-3>�:��܀�y������s>�j���c<z�=�=A�>k�0=���=�� �6��=]��@�)>ÍB���=�-ݾ����ߙ�$��U�?>s�=1����=�=gֽY���8��|\�=K�߽\�M���=���^۬����=��c>��=� q��o="\N����=�	�=���M���bۅ��f�=���h��=����m���o�h<<O�V=���@l�=�P�<��`g>��k��o�lwg�Eˈ=t�h���ܼ�E��!��=�Y��{���'o>���x�
>*H�=�f��%�<�aD��׏�q�M��<��콄���.���,�=f���%}$�၌>��޽��3���b�<��̽�ie��=o1�=��=t�9�B����Rk<�T�=�ϑ��g.��Z�9��=�:>!OѽD
�U@�;󜞽�������=���=&c�=������>�9/<�a�X�f<p�=_��L��=0ܨ���=�Q�h���0F��hν!$�:�y�v:>=d[�=��5�D�<��\�"�w��x�=E��ز">��<Wl�NZ��~�<�M���
>���i �=�V�<(3콜**�b�L<AC+=��MQ>h&�<�C�=�.�����<*���0���K=�vC�ÿ=>7���籬��h�1lQ>�2><�a��*�>#������=K:��&����誽pͼ=� �=�CF���<=�M�=�+\�y�=P�(��*:�GF�=�)��G>�`E>�o��$^ٽ�����<�"}�eWL=W�����=k�\�E�{���$>���#�!=E�d=}O�zb�<b>�=,i��:L<���=�m�>���V�{>��f>ܿ��L=𠙽�ǽ�	`�����'�����s�O=���=�~><]+����=t����?���=�R��<�c>�Z
�h�U>�v(�����\�ik��uz���7A>{��!�Y��;���       ��a?��?���?,��?[�j?٥i?��|?@Al?�c?��?��t?}Ɂ?r0�?��?��?�ď?���?/t?��S?z��?       �1Ȼ���=랏<�F��}\Z=��H>s�H�;��8�.���5�
�޼`ؿ��� �����&��Z��=U+	�'��>��k>���=       �?� @�ݲ?u��?nl�?�%�?ލ?�֙?вW?O�?ss�?��@:��?=k�?�P�?myb?�Ԯ?r
�?���?7j@       �x�?�Λ?�?>��?AX�?��?&�?�Ӎ?b��?�	�?ok�?��?��?_��?ޱ�?�v�?��?m�?舗?qѕ?       -���x�hQ�I$< �����=]*=|���n�<��2<�I<�	��:��=C>&函M����GW�;��=��޼      ���=f7���|�Q�ܽxL��W>p�/>��۽/=>�Ս���>��>�&�
�3�=ܤ�s�k���
=ľ=��>����)?>�hj=��>>��A>e�=�����d^���<HrH>laֽI<|=���������=f���o�=���dĽ2}�<�V=��q��X�H2=�a>S�ܽ3%��,W��>���H�4A5�
��<��>8��=X��=��=h^��*������<���ꔟ���=P/�=���g?q=�=`>C������< b�=|q4�̒.��>=�P>bTZ;{�l���3�\��=+=^
�Q�r��_�<��9�2
:���<�����P��׺��l�=�M��X�= ^>�h��7�=��`?=�>�A�=��f=�R�=chi<�u4��7ƽ��=	�Q��*�
��>�M�u=�D�=���q�0=V5=f��<13*��C'���=m�&��l�=j��>��>.	U>�n�V���={�<�yT>��5=)�l�C�#=(� >���{�`=���=��c=P0u���$�;i�ֽ��d�� �&�:q�=��ｔ�����={=�K���t��m>��M�|�o<��?��j=r�#�J�L=��	��1@���-=�CB0���=���u���[��>>Ɲ>ɩ����u=�|X��>Ml��|0����=Hy�M =C�=M�q��C��!�	=&c�<> ����z��z%���t>ٚ.����n�6>���;�T���ý�㜽���=����T���[e���]=(��f(�R�=��e����k��=�rм_��>E\��ʬX�%�̽��G���d�*<�~����^ɶ�~�����=��i�q%�=�4�:���=���=dv���R��������0>[���� ��?鼶�м�u<�Q8=�I�,�E��쯽�l���z�ä�<��K=�����;Ѣu�|�>c1B=U�A=�LJ����=�8>"?=/�=ā�͐r�Q���0횾����ʐ�����-��6�=̹��^�=\o�=hb�=��U>!L�<�&��O��>Qq'���=���=��=�p�<�ݽL�I<��<��r�^�ҥ�� ^7�r(>� ˽��Ľ�<��ꇜ=E{[�9��G��=(�R�=֒�=_n
=e�uF�>�
{�eb����½�/�1X@=7[��2�H>Z�<�=�3�ΏO=���(^=�J����߾�����l>���] >�/�<R*���0.=��=���>��V=$F-�r��<.>:�����A���=3%2�j^���=��1��<�w�Z�o�rF>�˥=h������=B�<����鼑qH�rl�<����Dݼ�*�=�/�H�2��.�=`J�=@���#w�m�<642>��E����<�����Q5��ϵ�/-��=���̼��=>Å��,ν�B=m�W����t��=$t��L��<U\E�OUH����=@ѓ���V=)F���G��.��h�۾�Q|��Hz>M·=fj���T=&���[�F��J��[ f�ٱ�O	��Gu>�{`���T�����<o!=�=�=Z�=����?����=@���skm=�{��l�F���=�c>p�#�~$>�;�@��=���=���=���a��<�<E���ǋ<���\�>��=j1{<
�ν��2�Z��=Zϼ$��<�9/<�I<O�>�o>��y=���=�ȳ�N��=Mw=����_=~������X�Y����蒼$⽸�;>[�)>�;���L#>��->�.�.�<���=M�뽠@��a
����ֻW��\����:��c=��9�ڡJ��!���޼�n�;��:�D���p����<����W"�=��}<�U�<]=�.۽��<�u�=R�8>����g�=����>����[>{Kb==���y>�>&���7�����Z>����34=�у<.���`�>�ʾ�־�6k�<�6u�A?�=Wɾ_��<��=cW����>�O��y�=�ۖ=���	>9=s|+���j<Vx|����=��(���R�n	�=��;ؑ���>ۛ��p�;1��4
��	p%<ضX=�ጽr�'�6C��<jM<��0���v�����g5<C�a��l콵Y|�t�=]��=�u�<H7�=T��=ϓ<�O�<�<�=Vr��m�K���r�=1���>���<K�q�=�m=|�½�*=��ĽYs<���!=E�l/��66&� ���w���M��T=���G=��R���=�/=#nC>�r�=Z��=�rN�wN��!&>��=V��e)��j��dҽR|�='	K=�늽�B>�t�)��=��;��95>�=|G�=.�'���k=�a�=p�H�o#=�zU���޽K��Ј����Mz">x/���t=�-=Ө��8�<�V�9�>���=��>����=��+�r����>v'<�����=i�=P(콬��<�������*�X��ⰽ����8��E�=$�˽
>�%M���G�p����Yýt�O��;���"��=*6i���μ:�S��(�==�GE����>W�Q=�p=��=�t��z�=^pQ��z��e��������<���D����
>���=�h>1=�$�l�=��=Z="=�\н\%�<q��<�zA���8�<J��������<6��� ϳ�b,�=��'��#G��:��B=�TL����<�3?<�G����@�>2�
>m~�L�9�z�< |ü�h���DU�~� ��z_��hp��"=]����38���<���=�h:�/>K���pA�Z���"��'�6>t�E=]����>�!:���ͽe��;�;S���>�@��(`�{�bB>��<y0���]��
+�9 ���;�<�6M= u_�%�,>�(5��=<�
=c^D=uj��������2�|`���D�=4!H�-[�=d��� �w��;��#>k�/=F'>��ý�G���>>>�R��p��:����N�<�:��h�_������j��}��,>��޼����^��R��<hZмlF<���t�μ� > w���\���޽ezc�+��������X=`�>���=M@Խ%�3�6Ej=1i�Vmؽ�!��9rF�bF> EL=>�<�>۽h�e��;�>栽�7D�~�R>㭝<��D=���ሽ������=��>E�]�M�=��S>
�l=��پ=���g(���"����<��a1����<K�O==�۽�lb<l����2���G=�U_=�)X=¶�< �>Z�?��:p=�[����=">jEv���^�Od �\s�<q��C��^�=�[J>c�ü�D<�c�=�=V�>*����+��~���Q ���=ƹ=�5׾��<r�&�2u�����v�n�~�V=�p;���{��:1=�>:��Z>��%>Y� �u`����M�ս.D�=�s
�,�=��0���׽?X�<2���a=��i= a�o�>n�<�m�y�b��P�"jҽ'v�����<>)�a����%;U�=Xg�=�4���+����̺��=)��=��=�->w�;��z� 
�_�@�f=s!�=�q�=r]!=�>��)>7��F>�Q����={�Z������}.>�~h�P>k'<�$��ij��\C��W��-&���7>[�/��>���4j[���=r�=g4>����w\ں�E
>.==��=a�(�p]�B�v�L@ɽ�Fa=�2�=`2!>��>�k=��M;w�����9&]��^�W��y����Q=�>avd�ti�=c�5�r(>�����B�<�#=�w'�=U�'�+�rԍ����<��>ڽAѼd˂<U�=�b.;�>�����=�Qr=�{>M*������a�ʼ �`����[ۼ<C��O�����=��A=!X�<q����=ѽꂒ��s>��$�=�����l��:�=�
�^pi>g<��I��P=�Y��L���
�=X�=m�����ߩ����=���1�U>�)=v�<�95�&B=�m;>���������;�s���=���<%��<J�g��F�1`��k=B�Apν5ʤ=�7�=��2���
���Ԯ�;]p�4u3=s�r�c!��]m;�6�H���>�j���>ʾ�=�^P=�}:>��<ZJνK�	�]ץ��D�P��=��μ���='�0=bG6�	�k�t'�ǉ�=e��=�}0>�R�<Pa�;�<��ޡ$:���R@=űq�X��;`j��u!>��;���׼�矼菌��t
�Nd����!�.ͅ� �=-�H=>�����<���<��A��5�h�;eUt��j�<�<G�񽖢���S�<�'���6ٽ ���쩣���>��ż��)��B#���H���}=���v���n����2a�+H>��9�=ř��O
ٽ���=�=ӽg�=��;�R=��>��ˌ<�<	֪="��;�5�b(��z�}=��p����<]�8>ͪ�R�]���g>El�=k��=�$G���i=���=�s��U̽����X���L=LfѼM��<s��_=^$=A����/=&�:-Q�V�>���=S�;��>��=�!>M�,=�6���z~���<>�*�ɘ�?�=pv�D~�=_
��n$�	�=q��<��s;FaŽ����l��� _=&��=��"�����¿ݽ|����";=�>��޽�z�=N��b'*��l���m�l|+>��=2�=ҳ��ע�=`��=z��=%�,>���=
��=�=^v��w:�
Ǳ�z9=j�L���s�B~�k���9��L�k>o��D�	���=x�A=-=������L9K�|�=�@.=��)>�v>�y��UG�>��=����m���P�q=��Ѽ:�l�Y��ƚ��7r�Wp�=���Y[��,>$���:>��>P����=�b�=�7������W��7�ƽ��U��с=٬*�x��=&o_����;��߽
�=���>�O�=�{ʼ�:|� ���p�=3�e�=��O��=2��=�eB>�Tۼ#�^=5������D��F��$��ZH�=��!>��׽L��=5�=�l�<R�=���~n=��=b`��I߼�U6�-I��:�ʽI{>���;7�/���һ3��=#&�1�y�Q42�b93>[�>J����'���C>�N>plؽ��-���
��|j=[��~�*=Ng=u���(�=t�	=�t4��c=��>��_�=i�z��+>
�3�k�=#V�=f���x=����"���u=v�)���+�p��ɼDe�=����R:�UP������*�?=���o��x�=R."=K	���C>��i=�^�<�A>��=� E=��`<<ya���>����=�-u=��o;��P�y�,�`�T�@����x�\��}?���w�R+=	4>��ɼv���d�D=摁>�_V=�*�=�R�2st<ϸ?=C��fʽ������:}�ԽUp�=� >�α��잾�M>Ɓ�<�S�=	�Z>��ü�^�]�Ƚ�5�=+�z=���;q�>wʞ=�<��%ʀ�T�=
�=[������\,	>U����X��˓����+�$��W[=G�=�y$�Ρվ}~&�%�;�A�=�D|��l�T��F����:�U���Ƚ�f}="<N>���wS���<�sH��*,<=�|�=�`ཱུ�˽���n���<>�q��:��ĉ=n"���6�ޡ��2��S=C|�<3��=8��<�0>W����
�J������N)��Se�T&���:����;
Hƽu�<	�����^�\>Ŏ�2�1���	>,��;/|����ȼ��=�Ǝ<P�<�܀�|��;�e=J���Y�>Oy�<^T�=]�G��=��4O>�B&=XC�=�W���YTнt��>�O �|�:�u�L�[!޽d��=�=�#<�\sk�-4�=�{>y�m��Ӳ=����">����ǉ��!=� �=�'U�`:>i8�����`=���=��$>�np=�W>�;�<����Y��& >a0=��_=]d��X���z�>�Mc=#T�=���<9�=�8=ޟ���4�=��=��<��c	���)=��,�����*_��8��:�S=;��%��{��6V�=꺞=K�<02g�H�F>:�=/�=E��l����=ҁ��p|	�H��>�=cC'>�཭Z9��"��A"�\8ۼ5���|>���<; <>u0!<HF	��|����=����W���%��9q��.���-R��c6<p�=;r��'����e�>$ �=�{��e��)��=:hܽ�==�=������G�
��ApӼN������=Mx�� ���ރw>��=أ=&ҽ�^�ӾL<������=Rww<��=���=F
��N��/>��\��AN=��J�)���,���(�=n�@=&����<C���� ,�<ϧ���>����*R=N�>�����,<�V�-����=^�pJ���/=���f��=]7Ƚ�����|�w�=b���������=+h����߽������	���8�U���xB$����<<>�#̽�C1���E��:����=��=���= ���'5ý�:8�D e�~n>=$D��V.�U3�Qݮ=([�=�%�(z�������?�=�~�<Bf"�/
�=�����V� �x���̽��=���=(-v�9�S�Fr��s&U��:���w�;�a_���>� �d��Gi�</�m���n�]%D=��9���[��F4>١�=�\<��@��Y�>zG�=�������=��[�=��!<���@�<�'v�'��D蟾K'��KGB���|=�n�����K�ļs(��M�<�>V4">�{�֥�^7���=9
���C�q!�=�6!>9��ӖA<6�v����<�u�8�K=�U�=�⣽�)��>��>i�L=&ݱ����h�>���꾃R>�;s�T��>a��<�&B}>	A���	>��>͵ǽ=��=�<��*�
��\������>=�D1�,M�=��<��غZ�_�i�Gǋ����=�C�<�)>BN��4@�3���]���䓾��8=^$\����H��=��4=a_<=��/>F�ν���"9�<s �=R��=�J;=C&=�;�+��2�@=Ls1�m�"<��=�?�=g].�n^�>fF�{#���)8�l�&��=%�#<|f�<n�@��to�<�i�N�\���9��F�=�螽���:��=��C=��=�}Ͻ�=�7�>���k���5B����R฽��l>�G½v_<�ƽI�w����=���;�0�<&�=��Z"���Q�y�*>�[��Xb�L�>:\�7!����۽��=M�]=d�^>�Ϛ=1��;*aB�ve���=3DM>�h��>N�hú<�s�=SJP��g��vx=�=��g;�$=�M��2�C=d���E�d�S;^D=܆�����>���$%b�|�=��;2�= 2�=�����0��6k�+q�=�.)=�[*�r#�����=M\!��4�0�E��$ŽXª��H�}��4aZ=��l�l��=��\����<{Zm=����,��N��=ǀ�=Y�2�=Wp7��V��2�� d��y<�칤�f={�%=s�ļ@^w=�� ;������=!��,1��nB�Wx|��B�=M�=E"0=�>�=��M��wB<���<-���>��8��=� ��섾���<�<��
�<˟����,X׻H�=Uf������,� ֢��rp��:�<�bO��u����=W���)Q�X����� =J�t����#�=��X=�t���=�̽`�G�0�={0=XP�<�;�W<�}���Ҁ<>E��/�=�[�L���Tһ���f�c�)}����=���=��b=?��=��ѽ�'��1-">��T=H���8=�Υ=u���R�y=w�;�G���#J���)�ɾ&+>����q��!Ѫ�|ip>�����zv�8�= {R>�U> �R>�>z�][��g��'L=3����=�ݼg�ǽ%r�<�V�=1��Lr��e�ǽ[�o=0��\�<�H=L��ά,=K�v�g�w���y>��9�ԟ�l>��m��u���q-�jl�����̉K=N�=Q6[��@E=3=�C�=��L?3�H�b�U]�k�9����$b
=�g�����=�Z/>��> 7�=�5�^3 >,�������.k�����=�/R�X�<�T��T�>T`�<�|�<2��=�C,�z>�=���.�<l���_�9=������]R>zv6=ݴ3=��꼵��������<*l*>GJ3�ǐ���yH�60���X����i���y��L<��=;�Q�HHu>V���L��y[��"= ia��b����=Ế��#>��D���Q>2�׽�3*��=��B=�l>��@�屽�A>`K�����3��73���[�<�H�?�;8<��־xVf=��*>?S=!���Xr>`Ŝ��n�<�=�F�=������D�V����L���'>�>/>��������冽e��<x�>gX�=�����9'(>�T>2E�a?�=N'۽���F��=3b1>�SM>Xr�>��̼1��<L(�¦����_>�~=�Ò�1]����ľ��]��$D�����v�<��#>3�0�L��=Ǳ��h������f ��G���<��T����f��=P�=�P�2��<"�~=��E>��=W����c��m�<���=��w�V: =4E�;
 �E�=�h���z=��������>���=_2�@v>ѱ�=%��=9�������h'>Z)�<1G��`�=Yh�=�� >ʮ���g��m1>��>��Z��*�+�W��G>^��<q�8���<[W���8��P�<�O��̢,���@�aY*=J��<	�ܽ��|;��C�Ar����<�	�l����j>˙�=����=]y<&�==/̼]����5�=��=��=1�L>|&���QݼK)�C��.$�=c�T>�P�=?>|d�!겼�GϽ��5��\��᥻A���_ּ�������C�>j�Bu$��Q���"����=ȧ���_���_{��L=���ϓ�=� =���F�$>J��</E;�_$�@[?�K�S��{�<�p7=�v=t�2�8�j��>'��'�,�<dJ�:��q��޽�`���=a9E5�=f�=ú���U��匽e��m����=�<���=�	�Όμ��=g�_>=�J��%�=9�P=��=�����Y��-���Ͻн��=�8=�ܒ��G���p��_�=o���:8߽(
ڽ�h<�Ž��=p_�<��<���;�;3=	D���}���>���n����|i>�H�<���uͽeP������@�d�Wk=vj�=����Ė3��`潵y����I�3�Rd8�z�"����=��=��2�C��=#&>�$8;��>a�
<���=�So���r=0M=�؝=:�j<�f��������K>_��W�=�b'��֞�X��=u颽��6=�<U��=(�)>�E���H>-!^���=!f���(H�1;��|J<gn)�QЅ=�		>Q�f=,6=�D�='����=H�����=<ߔ<�o2���M=�]��^.�<{�=�9��}��<�@�A�>�{ ��۽��2μ|���"����=�\V>�}_<��=?��=�����}Z<�TK>)��=�SԽ������$=�����=�9�<\3Q�f8H>�{<��V>�R�<��@�r�w<ꐗ=;�ɺt� }�<�{���6<���@�=��U>�,=�[��!+&�<���b�^���?1���a��Ġ�(M�=� R>�>6�7�>�d������,��<C�7> �4<}�*>�`ʽ��_��(#�4�> ��,�>	\���>d�>$�=%��=��;�%:���ü
@{� gL>{T�>`��NI�:c]�<s̱��|]>6s��_����ur<K?7>����.0�=�>`w�rl,>^�/>����v���p��<>�������ӿ1=ȝ'>�!���ᨽ�= >" ���>-�j��E�=��w�Bc=A"��,�z>�"Q����1� �Q�j�J�N=~)>u���rS7�"��=���=�%����:Ԩ{>����ǽ�P*>�b �A��=�Bc��}�=?8o�|��=�5<T��=�|�<���r>:kg=q5����=HwA����Z�=�g=�ws;������3@ɼ�e<�/��M >��,��{V�6WP>��>�����6Ȇ�?��=�}��f�|��:��<��=�1T��Ƚ�E$��>�=(=�=���=���W��Dv�/��~���[�F�T���=�� >Ķ?>�_=�����ߜ>�{d�Y��g=��=|75�c����Kk�2�=oc@��a9>�ý��=�A>�`L�E�E�-Ȱ�#��;�sY�m���ۉ=��ս�+�=�
>ۦ}=[|{=�RP���2��Qa<AQL�);1�f��=���>���Z��-e��%{ӽ�����6�m�$�l��a���>�̮�3sx�
��<�p2�<�<55==(��Y~1�9�9:�l>�*�ҽ�8һ����5G>k��=�\Ľ��.���<�B�N��4\>�=%��<k}!>�p��p��=9���开k =�����i7=��=ڗ>����Խ��>����=��h��+>�"�<lGh<��ѽ���=�Ă>�N�>�V�=Ӕ�<O?,=,��H�|:*>��=��l� ���m>���S�ӻZ�=�Rc=�>�Y���L)>��d=M-����;t&��?�<� �=mf>��^�L����=�S�rX�=��U�Й=a6�<�Q�=�*����C=�"�=4�����u��<��[<ӄ/=�,��=�U>;����X��%��}C�*C=�=�[�=A����x�=c���e��;�R=����=�"��~��R�s>�=�<� f=�w=h���Q��=t��2=">ä<�����3�D&>7����]i=?غ�P%>���=&�O=z���-�����=�>21��=:/��_S��X$<!>!=2����$�<��=�
��b�=��H9{�S��c�� 㽯�����j�����9�����:�<���Yd�H�S�V	�=�H�_Իc�Bt���.����<����k�3��� �����	G�=�,���i���B>*&��R{�׀��d�<[�ͼ4�=8ڒ�L>;
�%���F4��'	>�<Ƽ�[��\,ڽ}i�=�"�=�ǉ�����c�M�E�S����/?z��;K>㱲�@��ȤA>��/>�B�YT,<�F�>�����;��>w���Q�E�>>x>���=̌@�y)=�>�#$>��彭r�=zVy�٠=�B������<���6��^F�12�?U>���=�ǽkb}�Vπ���c=~[�=���U�X��6��4���<*�Ɯ�ӎ��H�<�d�=�\�=��.�=U����;~�̽s%N=�J�==�cfG���$�fx��L�Թp2>�D������	6>���*�=���=+D��N�O=7�6��fz<�B�=M+�=�(���0ս�ѼUX�<��C>(�>(���8#�<�k�`��;�p��4��AP��r����=�����r=�W�>}�>�'�<�Ͻh��8܄�G4>�g<�^8�D�<��͹Z���f	>���G=L�=>wE��/0���ɼ��=��⼍�-��#�=p�9�<������S�3]o;o� �Q�+g'�����!��*6�I����JM��=�2��"��=���=�#S�/����1>-��0����>�o�<%fK�x7�<$�ս	 Q��_�ڱ�H�d�b=��!>I�D�`�>��:}���Y$��eԽl%�=�t�=�: >���={R.=��*��?�=P�0���@�ȉ����d<���92��7k4>��޽�>Z>��B���ɽs�y��� >&�9=�8=��C>�y��_���q�5�"��<.�Z=�IEU=;�"��2�����<���9�=�8�&�}�6�=��~����򥼓���^>S�`�"R<��n=s��=v$�=(���1�G| >g3�'��|����N=�u.>��޼�j#>Dk���F�<"b=NoJ>p!�=��潳�A-8��hw�L����^�=,�:����&V���=#�;=K-0>�������=�N#>�!޽B�x=p�м�����=~�3�GT��P���6>��=��=�m�� w���S�<IW��Fj�2i��������<$�*=I��={�ٽ��F���0�����y�a��1�=�b���+�^�<�;�=�R�|�M�t��<�]�=jĎ=�/�����=��W�|Gl��觼a��>斏=0/R>߁�<0>b�>�<�����Gv=$�v��ui��a=�LֽJ� �|��=��=<FH9k�A��^">��<؇��c ����{���<ʽ��(�ԧ�=���&>��=�8|����:>�>NJN=�Y,<RF�=�*��~�=��u�-%��8>.����++��=5>���Dfp=M��=��|��x=<��<M�>�����cc��.=���>	 V=��;�3���>Y\>mw=3.>K�>k�<�ܷ���p��E��0X�=�/�c>bm��1t<�L�==UT����5�=�d��0�$=��4��� >����V�y>��i�%
��p�8���R��<�h�=		|��Nӽ�	�B��;�#�g>�9�<�-�=ms�<���<]�i>���=��R���4�<ئ<O�JV�=s��=�>Z�����v�u� �	�7�|��<�&���d$�ӟ3�[<����
D�Չ�<n�>�H%�潆r_��H�=z�}="VB�9�&�1�=�*g��z[>�>�@�=��I�������9�>l��������=��½F�1=jE��>DK��->0�=m�i�U'O�2�@�<ظ�진>�#�'����O�=8�
>^X���>E5��^>�݃��멽��>���=�<J��=Ͻ��q�=�쀽�?7�M�>��QL��F>xk򽕫��v��B-�<��=�넼�V�=VF=�G�=8������=p�g<hʼ���=�b���@O<]��=z��<&м<�����T�����<H��=T�U>nVX=Pz=Ƚ䃁���B���=f3�VT꽢�O>�B�����6̽r)�������=�{=(����m�=ׅڼ���=wB�=A���=������e,���ػe���[ڽ���?�i����:"��-z����;���(�[=�"0=^溽@k�=r'h��3X���m=�c>ih >��=�b��t� �RQ�G���(8�Ù�:����q)`=��=ψ'=���5�P=����e��e��=��c=h$�V���a^<���V���Ӂ���MH=v�+�FF��!Z�>����N>9��e�r����e)>�����=�fS=���<�&?�ż�1��<Hi�P�G�潃.�=�3$=�cf���;�A�;L�=f�+=Fd��r�V<_���eٽ�r��_>˽&��=��Q�A/s=4�P����KX�=�=f�ؽ�6���ՠ�Q�9��Hk���?�&7|�B�=�o_;|����Ȏ���E���A��ir=�Ь=�֡�����-��n���-A��yI��;�}�&�'��f�t���$�='O�=�Ž�������>��=����'�;N~(�=���-1�gǽ<��mI����C=���=�Ĳ�K K>}�7��=��H={{"�E5ǽ8o�=�=D4K>�=p[��.R�A�1�#����h���[l�=b�$���=>ڀ=�=]xl<Rg����׽d>?�����镍=��=�׀���z= ��l&>v��=� ��>Xg����=�V=��3����=L=]a�=j�d��+�:��>lC�wz>�.�=]�B���]>dڽ(�+<�f<�P>��l<�̲�
����D�=28ż�";]�f>��=p�*<^;缱��=^Nh=켒�.'?>g�_�< ��h:>��1�q-�R%��������S��=�ؽ�}"����=�7��hP���=P����=ф���<"�͒�z�D��)^>Tg��xOD��C=1N�<�!n=]��=C�c��b�=�o��ӥ�� ���(�<e����v:���<�g���1��V{���F$�2�=�p���=�32���q�x�>A#��J(�<�⽜��=V�=s��<�7��Au�����=k�^�İ�=�V>�߼       �6�<� �=��e�4�=�V�=�4x=��8��5�=�����=�L󻇥�=�[�=��;%�"�R
T<��=jm���'>�Tv<       ��z?�Ϊ?�z?Di{?�}?5B�?�u?�n�?<Y�?tA�?bf�?�x?��X?��q?��?k�x?�B�?��n?�u?Յ�?       �'�;j&:�W;�;�;��:���:���:��*;�/);��:ڼ<;���;��T;I�:�u;��}:��:��;�Q;       �&���u>6Ds>�m>��=.O�=_�h��Q�� �k߿��h�=���=�j�=��j�����Y���h���>?C�<=�X>      �>B���%��=���Z�ͽܪ>*�C<��>�4;:�½p��=U��|���Da=-���ҽ9ľ[���yu�<^��=x�t��� > 07=��p�=�*!���S�B=/4>���<J�"=i�۽bi�=�>R��>�9G���������۹ٽ�[=�J6={߽��>@W,>���=�x�,`�=ɉW�<�=���<�i��h��uxJ>}��5H�=�W#��U2�$u0=%	ֻ��@��"�m=�r�=�z�<��==����R�fFJ��y�=z��!��=G%> �<��3���V>%A�=��ż��8=�O�>;,�%��,�P�ҙ�=���;0��<���l�^�^Xཎ�|��������Or�=�����=�F��:|�=�` ��u�=��J=!��$
N��R��a�j>�l��w�=�M��ͥ�;*>�p�=�R>R�Ӻ�87>�V��T�;=���>�]�<��>��%���=#܇��t�=($>�H�=�R�<�=mE�I�=��>7��=f��=h��͂2���=�sB��rp�чr=�M�<��`�k��hY�V�����>��C>v�ʽ��Ͻ=�4>�^=��=r����Kv�-��k#>�s���սɡj=Ѻ5=͋��l=����=��=��6����=��e=�}e<��;T�U<^�>R&�����p�����<������&=����/>���=k-��?X����=���<���=I�z��=s��7�P>( �=��;��|��ء=w�[��%>`��=���0�B>�=�M�N�<8�f�;5�<�M$>`v�=Zޗ�MꑽFs�@�2=
�X��ܻz��^ڛ�6�>�KB�hо_qJ��:��1ֽ=�x�=�-���o�;_�t=B�-=vX!������P���;gB������B�!�֠>�S=W�=U*����=�y�=�P9<|^뽐Í=�>Y��=飨�b��v>�-�x�=~�ýgF��x��<�O�F|�>��"�>C�|�>��D����=���=2��=�����fZ�6/����6�A��zW�=��-���.�X�P>4�N��F��k:>�Ƚ�gy��"hE��M�P5�=O�"�Mf���(=�i��(��#�D��S�=���x�>���;-n��a��:�=�Z�=.�=h�J��=�=a�&>�qӽ��E�|4<^M�	�(��:>�n��D+��
�=�,�՜��s�=-�]9��3>�v=
 ��+����e>�Au=v+$�ޤ��W�<�s��JƉ��ۙ��M>�d��:�ֽE����N���^�Q��">��K=��k=��,��;��S<�@�~v=�1y��H=��B�5�|���V��=d�E�]ϻ=wu�=K������}م><��</�=<SK=�������̣׼�o>�����ڽ�j/��9.>d(�=}�I��Z�K�;u(=�z0��7
����<�b���=�ȧ=��=/��=�/}�h#a����e(����=X$�F$�hC>)��=�����_����<9!�<�I���i�=��ĽRي=1_޽v�@��!�;���\��=>�XϽ�uY<,3�=d̕>n+�=u����Q�r���T^��=�4�=���=��=�B����̼��=g蘼���X`4�ZNH>�n0>\� �tq+�3)��ׄ���;�*�<nV�=���=d�"�������=W>��<��ܽ�+�|ζ=
�r��I\>�,���ۖ=J+=�`/���i=�߳=.��=]�
��o4��d�=R����[�ޑT=�<��'�u�=m#����>b�H=���0R�]D�<g;���y��S�-c���D�=Q0�>#��<~�>�2��
�� ��/�=h>b��>篵<6m]���s>任{!=->��,��Ј��+�>��0>��n=�d�=� ����I���^=�#Q�'�Y���;%~b=_�>C��=C�	����ߐ>(6-�
�ཿ����*��c�����>g�<��<�,0>$�l>���_��<���=��ʻ �H�m.=�>n5��X�¼Ŧ�C���ak׽Wq��B���4��=MR>�J���pM۽b��󸼗�=ј�=�4�Ɯ߽�A>�����6>;_��^���R���4l���-�Na`�JtN>ZϽ�B.=Xν�Hz=cuy� ^m<c�?>B	�=H�����=���=	4*�A����24>��*�{���>���Ov���v� �=a.>?���f)<�u����$>�ڽ�޷<͎�=;6�86ջ��;3DB<������=��nݽב�=���y���#|j=fN�<�����1�<g]�=ŗ���O���*I1;x�==5U��_>A��<��D=�ֽ�R�L�J<�����\Y���SbQ=%��=;S߼%Y�=G�K>��e=�V�VQA����=���<�����������b��l">�㣽��=��B��`�=&��<���=8Fe��v�=��0��\7��g�=؟�l���θ����=�3��A$�r0R>��ڼ�̽|Q�s��= �=����x׽D�-��S>��[� Y�G�"=�����*7E=!�<\1�W{��=�ef<�n��5��'=)cʽ�b�#Q4=>]�i����N��0��<@�8�.��C���Lk!��>=����˽9��к �8�=��ѽă�=?g<����=�&=�T>�w��_*n��e>�G�:�^�;�K�#�C�d�>�Z�;
a�==|�;��M�s<8;��"]=�mK<�/�aA�Q���F>���>��=���3q޽%2��P�I����=��
;�hȻ��r��F�=����|�L���t=�Z�>�Б�PBs�%�~�[:�����<A�=�W���|��{�=���� �=�j2�oS�=҅��\E������$ν�0J�HU���=��=f��=g݈�^jJ=��'=z�ǽ�=�����->��p���_>�>Q��<�$m���a=Ț>���җi� �b�k��>�i�8v�=�(>���9�R>Ӟa���2	=<�^��V9���3���[��E��`W=��=m^>�E�<O�����=��%:f����=�k==2q<jP���#�@	>��c=έ�������2��� ���
��ek���r<i�/���=�y��0��K��ѧ<O���:�Lم���0>(�>��=�V��h�;�"@=�-/��Ŕ=�O�>��/=�t�=��>v{�T�����*����f>4���g�z=E==6r�XY=�F���f�<�-߼��e=⌽��l���&��z� ��<t���#��4�Ij��?}�=�<Hu�������˚�ا�=�ƾr���I��=r�=L��J�o������O>l�Y�[�d=m�|>��=��=�(B��Jl����=Cs�>+���6(�<����է�����H
���+ܽ\�>=�=��o>����>_ �=x�.>~�]�_�p���&��	>��4>,s#>H�>��2��m,��$��
��j<7fc���=s��=݌>�s>��=���<��U�6U��>=�}����<�漽g}F�j������={������2>7Ւ���=�� ��]>;>!6w=�c >����� �P=�\5=俷=Nh>B�J��-�=H1��=2]=U��>�f�ӿ��n���(3���O�)����j�U=�v�5F>1���Uq>F��=���<��d>OK��/B-<�W��Q�'��H�C��ý=�1=�|!<%t>�I%=��>/c�@=>-a��e��C6;ty��9�o�g(>�����輝�E�%�>�P�=s3r=���>~���ǣ��w��
��������=��ʽ.>y�򗪽���=�"<τ;I��{j�=���ur����>�ʉ��Ä���	�o}�=��J��[�r��;]��<��1��|\>�oҼwM%�qSd���*<�wj;��=o{�=8�-���q��B=��$<:ȼ��E�E�)��>UY��3�<�F-���7=A /����<�^�<s)��>~�a�0ɣ�s$S:	�>�I�>"���Be\=�;s;�^�=x�l�iE�YL=*���I�;BI�<o��j�> �=?8��\���U>�0F���	�c���@�=2�
�IDU>��<k
<=S���ҡ>�VR����������>�\A��f�=���=e��_��J��ȃ�=��=>���Ł+��� �%�z��L�RY�=�F�V�޻�N>P����W��Ă�������$t@=�J�;�>�=��;}���i|<�5���=��=�_
�(�����U�D�X���W>�b��5>��3>�9�D�=��=4ӎ>HD�=�B�L/{>6g7�.�������|�|)h=�ƿ<G�役�C���s=)������=�;��=���=E=�៥� ;2=?g����f�)_н��߼�e?>do���6=ڕ'>̀=K$���z��͉Ƚ�eؽܫb=�.~=o�&<����uj>F�=k�1<mą��A*���&=`t�=Y��>�n���N���;=_<_���=<	����:�@>�du>|��=���<�,���2��%.� �p=<>]��<�@A��!^=��ֽ�T��e� ��>����Z=�,���=K�>b��=�?ؼ��M<���=�U%�5�>�t�=^�H��~�>����˘���[�x^t�w��1`Y�ؒ ��Y<��q;ȄI>�8
<�ɻ+h�=���<'��y4ؽ+�=a^�k�Y�H�'�I�įG����ҡ���B�=�J�= �]>��(�eн	�����	<�������EQo=a'��'[��,>}=>�ǽ8T:��%��^��|��6[�^׼�Ê�Q �J8 �����ް�l�=����88���^��b��Ow7����=|�N=����_�ƽ��m����f�Y=�֕=�*�<Y�<�F��S�= �R��+f�+L����Nz>���=~�="$���dҽ�5¼���Ê<d~=j>�� �=�=U����<y>6=B��>�r�<j_;��=z�����=��4;���<�8���=S�V�Ζ��/|�7�ƽ���=�\%�+7a>���C�<o��sm[=��;z�M=�~r='@>�ũ�nt=ؽ��a=;W?� �p<&��=�P�<�̽�ࣾ���:G3=L�$�S�ڽ��k=9F$>,���#L�=P�ƽ!(���b ��g<2�x��Y�<�~�L\�>C[[:!3�<�BI=o>��a�9��=�1q�4ϓ=�Խ6s9�=�l[�=�p��"R��	�� �>z�����<t�>>v��=Y��b��<��"������m��
o=,3�<:B9�_ n>脺������G�n{�=O ��/+�a����-����b�����y�Xg �B��=�#=���<L�w��`�=d*��)��s��<��ۼqi��\�<�uk=BcF=�,0�~�d��/<�v�=v`�=Y�\=�}��U��r&8�<,>�'�
db=�͛<�b�<_/?=ݹ�=U�=�B��f,ܽ��V�Y]>P���R�	����A�i�=��=�/����һ�����=L�=g��<�;� B�����/�q=�k�=ܑ�=Imf�����<��ϵ=�>ٌ;�i]�03�<���t�!�

Q=�E=9<(�9F2�
�>�~�-ٻ��H�H=�.i�3Z$�������Ҿ� �����ޓ>k뽳ZD>Y�#��]�<{�U�� =��N>��_i>���=�@���� =Y�.�s=�����<���>P�A>�g�>-�"=5��=��0�����6��@�=��#�V�>�}�Њ�=�v8:�l>�[=���=>`�����=�b>���B �=WH6���<�3>�2=Y:�f٦>w��<0�L=�)`>�!��[Z>>�2>'=�0��G<�#0=	���Ր�S���U5���&�q�B= �+���=!�S���<�q���ȕ=q�E=Օ�\3����=1��=��V>����N�#>$o����d��">�u�=���<���?(��\=��<#(�=�.="�W>4���]<hf�>�w?��J>���>�L<9ʎ>��=UBy=|�=�q��A�j>�'?��(����=��l���|�[]���4�;a�=ݫ�=L;��q�<�����'=4)ʼ�P==�E�ն��p�=� �'X� n��cW�;����=��*=-�=m�=����?���9��O�(��Y&��Gp=���=ހ�5�7><V�=��=r;<e�0>c�}�B��=o�6��=�2꽞(�y��=v��'>��p=yy�=���;��ݽK�; �<��G�\)��'jn����0\=�ٽ�>������KU��!M����<�>X��<�֚;'�7=%y�o7����=0��<���(k��"S>Ԅ��q>��ܽ�A�: !>F��=�����y=L�3�k5>����i�B=CD�<�OĽ�>�Y��h��;�ԽKH �|��=8����KE=���z�=���=P�+����=#{F<r5὘�h������н��.���<H.۽�y�<Њ�&��@֗>��=�������5�����.M�j�ͽu���ӊ=~�>�7I�R.I=�#�9$�<6���C����S�B<o���mT;���=�@�;�B�=��ν�7ĹLh���>==P=�n]=�n=Y��=N�Ƚ�G5����>��-=U�{>$���4]1>�ʽ�ؽ�0V=$�=�۽��r�=��=���ɽj��=1��=F�<iB�=#1��ݶ=X�E>n�r=��A��FI>����w�q�m���;=�f4�T>'+$�^� >�E>�>��|D;����C=M^2={ȸ=:�;\L>i�(�7l���Q>>�a��p�����;wy۽�� ����=��>&��1��M�6>v:%���k��:]4�>�>�F(=T�ێ< ;�lD>�7�u�ս��<�����T�;�>��b<�J/=[�������_�s,{�h�h�Q�����>�T�H>x
����=��\>�=���<	��=����M\�s�ӻ�C=��s<�$=>J��=/6��}���>�;�g>u�\J��I&����D9>SD>�����=ۄ��Y�p�� ռ}	>pڋ�P���R��!�={�K>n�I�R�R>��\�4	��.�	>��pT4<X������i���<�7�9�нL�=����y��4��=���=BR�=�&��P��=<%���σ�e�<ǽգ���=8�	�q�� �>�j0Q��>���%��b9F=@m����"�^���j.=B�1�����
6=��ڽc����)=��> ��+�=�F9>`[>�Q>f�=8+���C����=����ǫ=�"n�	o>j��;ܬ޽�@�=z�=�A=;'>�(��󬽱��j_u;��a����=TV��u.��DI>�E�����da��f=r�<!	>#�i��1�=M�x<����w�ӽI_��K��P����4���o
�-^T>h�����<m��=��P>��=x������=+Y��a�>���8=�}3��-�>I�!>�ދ����1<(1�(�B����=<P0>�2���-=6���3[����=���=<��=2���������Q��=�>h�F�_��=��:`%�W���Ƚ{ݽ��=�iQ=��>Ϋ����0>t�t���&�D�/��9w�=�v=̍	�Q?���ʽ�n<ʆ
�1��=��=/��=��e=��<��=��=���=�@�����Jʾ���=��C��5��V�""E�9V�N��;��0�?>ǧM����+���6��LC�'�=<���Oڗ< S��!G��.߼��}=N��b[�=H��<�-�0v��E)(> �`>���Nx>��g�5�(>U8=�~:>�)���$
�6�g=V(a=o�D��<xH�����w>t:�=��c>�x"����)��whI<~ʼ���5�)��c昼8�=��n���>�taV>+�׽(^P��-�*�t�rr>O�ڼ���<�����н�ֽ��������ݽ~��Vo7� �S��3ʽ%������޼��~���!�Ι�=���D�N�_��eٽׄ�=G�#�P\W���H���r>�D�<!�=��D�N��=�>�:��-s*�͔=
h!>���D9�=wȚ=G�P��3>�B=����v<�E��u�<�!M=l����|:*��u�k�6����!�=����/��=a~x=`�)>�ɽ���=mz�<N�%>~�H�O,��Mrɽ�Ѽ|��=?o|=��<��=�`��^��tok�J�X=�9�������z��?齆P����=�[=�2=�m9�B�-�xd�R�;X�=��>R[��=�F�<������<R��i:�x;:=��>�Ҍ�͔�<���=�j=@K��d��mA>�#��4��T%=���;x�H��c�;��=�ظ�&Tg���<+p.>�zQ�����0 ��_����>=\D;��+��8(��ʭ<+���C�=��?��[�>$_�;}�|�6>���=0�	����7 ��*6ѽӏ���>M��x��=|�<��=�G>G��J�����q�=H1پau1�
i����{����<�p<��#>/%/<>Uy=�]=��K��#ż��o>�nԻD��
�����$�
P�D#<>.���l�>��7�.A����i�K����> >Tt���=�w>D������>u=ܽn�ѽ�>Ѥ��M=��4=�Y=?n=�n�Z����s;�R��&@>��<����C-��Ҙ=T�Y�V��v��=�r�=G{���C��8K>ql��A@=m�F�
q4���l= Au�8������;	�Ƚ��&=P����=��=����� =�{=���ʐ=�ԟ����ig���=��B=X��̐_���s=�&=�IX��^ͺ4�ؾ�S(>�[j�i@�=�`1<�O9��Z==_�����>��۽����-�rӳ<��>;{2�_Ae��( >`��==�8�����à����=�v߽�*�=v�^�\�l=Θ>>KG�F�<�6�h
�<z`�;Y
^�C��<��%a>��=�T�=�9��2=仏��a���7<�0>.��=R��s=�	��D�Ƚ������=	��=��_>�c�p=�� �6����	��zN<H�=0�>M'w=3�0>a�$=p%�=��ѻ���=�k�����<G5���f�>�B���=A@�=Q[��->\ڽ*�ӽ�]���&����Pɨ=�;ɽ�t�<M�<�Jh���<�"�e<>.�ۼ�>Lm1���~il>��,=RO�>ۊM��u�0e>u=#>-�#=�g�=�8
����:>~��=S~e�Q�M�4>�8�=����Ea�Fa2�-��;���=���;�KĻ{�H<ⱘ<�nY��>sc�=��
�	h>Õs���.=�W���m�qP�;N�Ӽ��>4�x���Q����5>*g�=,�>��<ٯ��k�5>�5*=�{�f����=�K���u���
;��:���/�4���ӣ����=��>{m�=_$?=��8���_P�7���:V�Ǐ����=��ž�ޮ��;��M����Ʊ;�䇽��,=g��=�>dU�1Ų�� �G�����=��ٻ��E>��\����p9�5�:�S>)	��K�=��>_��<@]>Z姽�i>(�>=~G��I=�f(���=Kaѽ�>ʼg<�cF�=�d�;QL�0��_`�� >}��=��=�3��M�<U>̒F=���=p�t����:{�
�fa��ƍ�>A�=���H�,��y�=r�>	��]mv�0ޑ=P�=�0=BJ	>�"�]��=�(�<�g=m�(�v=���$B>:˦=��<[e=�i?>Z�;>x��Ɇ�=���w����)J>7��x��=�>,e��
�N�"��o?>����MZ>#�����`�=�2��]���~N=�:M>���=E��=+p�=<ަ�*��R\�>���=��輺��<@��D����Q�l��? C��4�<=l��Kg>�m=J�=�����`>��	�ߐS��<�w�< +=1�}���=ߕ�`����ؽ�����##>��=�R�=�G�>���ꘉ=t��=�Fٽ�+!�,*>��7>D\�=�9�<�˕=[�Ͻ6dy��5�Q��<�~w>I�G=q�>4&�>w��=�T���y>�����M�=O1ͼ<9սU'�=�{c=��X�t�̼jO�;�n)=t� =�-�>GH�:�M��6���[��z��h�<�dܽ=�_C>��>\"�����=h=��=Z�b=F\���<jv����=}�j�QCb�c]=ڂ�=�}
>���V���}�=��>Ѣ,=[��=�sd�( O<��@=����!�>�8�G�T�,
�<"�=a�>T��=�����=a&=<oN=?��<��_�9�<b�;%����_���]>��9��nq>p�&��T�=+�Ⱦ���=�
��⼌�g<BV�=D=�����D>|��]B=��5<$ڶ=}g=%dN<����M�<`W�N>9T>4{���>�>>]V�<+��m#սg1��=`�>�k������~:�C`Y=�T=��?��t>W��=<�<=H�u�+� �@6=x֑�<½����xfi��=u�u�����	=2|=���<�<��b�$��="W�=W9>���><�I=��,������3�����=�l=�,K�rpI��D�=���>(>�bP>�����h�����]�1�>�}����?=5 ��I��y���b9	��I�=��<���=�6���;�Hn�oK��=:�#=Y���Ik=�8��-:)>��ֻ�:����T~*�t='=���ֆ��C���^R�<A���v=\�H>���hơ�B���z��xm<Yc�=�x>U̽=�J<ˬ����=׵���#9��J0���*>#�h���=>࡮�����G�@I���>�= �ѽODm��/6�����=G6>ٷF��&>�3cQ>M>�ҁ�M��=�ky==�=���=gg�=�Ӗ=�tN>j_!�q�>��=Dl��`Lb=���������= ��=�uԽ��=���=�l�����=��y=F���oq/�Ђ�^8�k�=U�>L=.>���=Mp>;�=G��=�譽��L��@��4�ὺc�<�yԽ	��=%T������@X�=_>��5>��f���x���Ž�>>�M>����Jk�x฽�7=�X��A=e�ݼF7�pC�=f�	�������8=�0�==�=���Oǁ;�ҽ�Zx=h���3��ҽF���첽�,�+�Q��A�}�L��5W��T�y��=J-=���=���<����=�� ���H=�=u� >�-��X�/q�<�<���=ߙ�=���Kn�����<�/��U>��]��9սWҗ���J���m�Լ�=�^�A1���-=V�:�==�"=�R.>�P���A�����=?0�����bsg>;��=epz>��0��9�>���=Z�?��c�=i��<%��&����v>@
=1Z>Q����d�;8�<�=C��!鳽��ҽ�=��ԽnZ>!-�<ٻ���R>�����ul>�N�=�]��@r��71����.�$�ɻ���=�چ�iȉ>�,޽H��5MƼ��6>o�H=�U8��`��[�<��<D|<��ީ=�Ӄ�����4��\=��=mD�<� ��#?����u><�N�=l���>��=�6�=���>�c���˞���ֽ��=����NL�=�y����)=������>�4=�6�=�6�(��=�5�=8�<�T<��>v}l=��~���~=bJ�;�'����;��F��w׼�A���>�Bt=�����?��!z
>���=��^�1�d��3�=�����F�6b�==�<���<f;������=��*>>�(�����<�4��S������w=���=M�=;O!��I>:�F>o2 =r�X�ʽx�.=�_�=��<WF�+&>x;Y�Ġ�=8�r��`l<�"==�ֽ��v<���T�=���=;�����=�>Yx<_����<�OU�<l��=�������RK>p�=$K>:�\<����_=ґ1>>���b21���>�w���Q:�R��~�q������y���>n��z��5	�;.>�?g>�z���0>�
:�Ͻi���Jټ��1>�<��ҽ�2>e}	=�}���n�[�B��<���Ph�0��=��ܼ�mH�t���4
��|�=�EԽS$ڼ����=�$�=@���e����3�=1o
>d�=���ڍ�=����Xx=�0���48��3½�����bk�H,ʽ��9�wC>��=ϖ&=���u����c�_
�=Z��=:�O>�'�<A+�����MS ����=�87=."t�~�!�d����J>�s�{5��s���?�<j�c>�>a��>Gܽ7�V��>�)>)�`>	�=-�=֐>?�B:�˴<e%����_� ���F��>��(������[�ٻ��=�><D�<>�R�=��<.�<�o��!i<W�n�=y��=ye��Aϡ��9����9N!�jQ=��=�0뽵���%>\v ��)��q��E�=�����w�=�u�=�Zy�@R���>�&�<��3=܎��bZ� �)��!��H���Cn�� �ב��UG�a�ڽ|J%>__���c�"�"��%�=�6���}1��:}��(�V�v;M�<,��x�p<*)��;�<w!���wH=�l�=  o>5Y.��2=�}>6�)>�E�OGa��7�=#s=�k\�}{�����=�`��k�ý��0>�6����ҽf?�1�>�ө<�S��Q{~=L�=�����ܽ��;9�|�z��=}���b����X곽W͞���*��.��S>��3�
�MD=�4��G2�=��b<�'��h� �*�M�(�:>�-�-�7=*����R�K�>���<�������=ꥀ>5&��W��j5�1�[>��>��$�p��=-��=�О�!����=:2�=mp>��>�QS>�*�=�>���S>H��=G�^<w�u��1���b�+5Ƚl�>O�Ľ��м�@>�{<8Nվ�W��`X�~K=��ܽК�����<�ӽ_Kֽ�
޽��r�܄���&>���B�[<�~���>�B�02�_�*�J*���n��	�=�ݯ=+�����<s��<��ֽR�t=cN��ڟ���~>C5���[=��7=�sn���=��=�3�= �T<�`�=�h�=��6����;�߷<�\Z�
��=��~��1~��>��'�-(>�b�>9�=�� >g�������$Y�����.���b�^��=ӽ>�A߽��>����<\������
7�>'��:�/�g�=dK�[�^���=�P��#B�:�+����+=UN>f�����!���� �a����ЍK�+��C�>�w=�s�;��ҽ�gҽa�o=	S<�3�=�-->����%�:�B�jo=��m���6<h,�=�Χ�����W�K�� =m�n�*�`=�(}� �<��(�y�����J�->;�R>�4>��N>DE>�:�<�2>|�J�>L�MM>T�<�Z�$CG>M�!KM��>T��=��|�q������ɽ�(a>S����L�=��C=��Ā�!����_<A�m����TaU>l2�P�H=�b�=�w�=!.�=ČA>�6ֽ~t3�S=��,�<� >i/=4�d��;1����=4����
����8_޼�q���>b�k��|=�r	�B�k=+L��IS�=�V�=���=_�a�k��=M�d>�����.��YZ��XI�N,�XYʼ �=�2���٧�#v,>�)�=�7K�q�=���=rQL>޿f��rK=>�=0���_W>Rl���{���=��;8m>�� ��D6�� a>���<�{z>F}=��g<�fS�h�ؽ'it�"��<�>!�<��q�=Ͱ뼽t>R��;������=Y_�;�X<����q�=uâ=I= ��=�U��k����<��=w�(>����!L`=j�>ӥC��a�=F\��HJA��}��r t�u���@xA�����Z�/�EN���{�=q�?��\�X��=����м�P�<�=X�v��=�2�=nZ�Y4���@=]	�=)��C��+>=,�f�0=[��<���;�3>8:>�G�=&^^��VC�-��U=)�,>��$�|ټ���d
��>�<�`&�G�׽�0>4h��x��=���<�Eb=       �$�I�B�����Nw��`���[�5������D�@8�g�A�����ԪZ���?�:���yV�����޶[�w����#�����       �G             2������=�T>$I=V~�=*
,>kZ�=xa�=Ǽ�=��=�zM>1�<�}>�M�=�'5>�"|=���=`�=>��=�_=       �G             � ̸���=�ý���Z�=UN��=�Vͽ�ļLP��Q�EJ=z�;cV`=�Z=^��=CH�<�%m<���<���       �Ѿ�8��֏�������Ø�L��2ſu��?,�t��ߩ����������E�j?n�̾�F>�ˤ�`�a�A��>       I�o<�>'G?����>f0�=Ģݽ�齀��>��<ˀ�<���=��>�fɼ�-�/(���m>��=�2ܼ�d>���=E�=s��� Z�h�_>��=F�=�~<{Y�=}�ؽ<��=-a½l��=Ugռ��=1�7=��=>1��g�\>�!�6�C>��=(@�i1c�n��>���=�� >B|���սF:i�1>��W���\>��>�WT=�	=�*<��^��ؾH�>X��>�	˼|��=S!ӽ$��6�]>��T�Z��>һ�����=;��<�T�������=� �=<�	=��>(�=��L=*ʃ>/��>����l�H����a%��~=wb�<�X=G~��'8Q>���������<��=���=�����d�<��L�>/���,��d~�'!�=�k�,��
7��k�[=Q��q�Ľ�9�=y�>��8H̽:���3Ҽ�A=R˽�1�=�
>7�Ľ{\�=ye�=���=�8O�(pI>ײ>��=�/�ھ���Q<�h=�d_=��=�d�=���=m7 =/>g��=�X��7�3;P5�^٣��q=�ؖ=´��CdZ�����L\�<?�v�莅<�,=�`�=I�E<�|���e<��K:�>C؁��(>_RQ>�U:��= �Z>�0P��6���<e3M>;�Q����<?_ƽ�b@>�Q=mׅ����<���:�=�;F�<=ҽ[�;~;>��Y>@��=�-輫|��r3�ܸ�=h+��^]�G^�=��>ݾ�=�ռ���=�y3��vK<���� w=���=�����0�=�Iy=|���*����)��=La=	����	=1��=�t>�u�<D>+��l��=5����.����<ꎾH9��ȍ�=�Ή�x�B� �=�7'�����6����<Y��=Z��= ���D%>��=i
�>3��O��<�	����0�ֽ�R޼�;=>��:�{��]���_H�&�����=.��n�7>+׭�
~Խ�溽AE>8���GK=pۼ����>V�=����İͼ6nr�B��:��7=�Gd=��;�-���3�<hl4>f�轱'=l��S���=�`��Z{�=���=Z�M��Q=�)��;>�k&�WM����#=�������<�P�=d�����I=W�G�]��T'E��� >�#����=�K�@ǟ=�o�=qν/��=*�'���?=_��Ǎ��=4�>�32��Ѧ�:��=͝e=�܅=�k�G.>oG��ڋ�:�>�|�M���-�=���=D,.>��Ǿ��>�l���<�Ż=�->�;2�a6�=!� �\؍<��;�a��=
�=1��=���������=*>�=h �uS=^���}>m>$�oݴ����=���J<��=�A�<��Q=�?�d\D=T	���})�Wr=���=�pD�_�|��Ι=Aƾ=��[���=�?���cͽg�6>9�A��
 ��N>H|��H=wP������k>��y>��˾�>�����D�':1�.��=���=����`>>-�H=8��=�p���H�<��ӻ�l=���;�DP>���=��<x��=��<&���A>0ڟ�В]=i;��T�=�����%/����<���)*�= p׽WU/��1��xd�=LǗ>�����w>�޶��F�����฀�9�>Z*����<��>�N�<��� ��E�<!��_ ���&n>  >,H�<�Zc����=���=oZ�]���?�l>�r�=Q�e�	�4<�2�=\O�=���pY�<�ls����,M�=�����4t/�LC5<��9���I>^9 =�O=d��<jZ>2l�=U޾������l4=	�Ҟ>�����>?=N=f�>~��J<�mk=4��$�ݽ$��=����SI�D��>��>����� j=�Oh����<�i=�)��}<�">\>�V����6y&>�m3�z=N,���6!>�`��P;=��ݽW�=<��=0$
=���:>^��<�P�<�|5�Yw >�qV��:�=��.=#t=4��==M�$eo���*=����Ӆ�=��o��N==H_�=��<��<=��<VO=��A�FX�<�H
=Y̧<k�>=��=/��<�<��|�ƾ\ݳ=IN�=���=W/>�֛L�M��=��$�	�B����B>�1��_4 >�|Ҽ�6���޽�M���ӽR��=�ɽH��=^Ԃ=mi>�=�^Q�9=�=p�w��-��t8>2@���LW=>�+����#��<�͍=�o[>�5�=�6M=�M�<�.�=��@��C��=3C>+��Л�=GJ<;�y5=���<�����>鼡>�l�=lS~=�k��&��=����=!�	>1$=�����=܆��͐ü'�@�<yu>Ϭ�<�U0=�������n> L�������ϭ���=�
�=?��=���=ʴ)�h�H<ʮd�(<p㉽v �<->=���/�`^>B��V(=�}�<�=�=��?<�7	�/ ���:=	��;c�c�Y���b�%V����>$����>jU�PN�;V-r�N���a|�<�D>�1J��$�=rq���=BǼ�#>o�ͼ�v��7�<R�`��<�,�r�=�=��F��D�=+Í=��i�t{>�6���7r���=�A%�Ґ1=�'@��>&=;E��n>���<M`��C<�ཱི�ֻE�$�=��'>��<��<3�8=���<Aħ�a=ј�=lғ�@S�<7�/>���<��W���=[��<���=��=��/�5k�=�N�=�ڽ�����>]W�����{�<s�==-.>�ý�ͅ=A:�<��=�{���	>_'<畽Z'D=2ჽ����@��|;)���=�Om�j�:�]p���h>U�|��k�=��>b��<��=r6>>��=Ad>T��=y��=r`=e'l=�^������S=X�>�Έ����<s�!���e>k�μ��=Mض�ml���v0=�(ۻ���-Ю>%J5������h�=�]��<�m'�1�:�0��=wt����8>���<L�>j%���нt�=�t<����0>����q>U8�!�X=���=�R>Z=A>�E�=���<)��>� �����<�μ=��M�o�n=�^9�&>��S�!̊=̝��x�=��U�<��h�
�m�=�r�>���=�T=���=«k�De=��L>�� <��>�#�=����Vq�;�]�=�O���2y<ڋ ��sg>�w��06�����<y��!��=�|;��R�y��;��;t'�o)6=]��N�Q�1�>���<�=c.彂Q�=ћd=�j�ħm<�FY>Y[��e` =<ռ�
8=�L=v�#��.j<��G�a�D[.�s�ӽ�vV=�7ڽ8>��&=���7�=��� �7�q�f���
>$9;��,m>���\~K>(Ԁ=���*Q�=���=PV��p� =��V>˛�<E9I=
A�<3�_=z�����Z�j��"�=�P%>_>�=u<w�>BB���[��R�;o��ҽ<�F�e�j><޽X�;>�P��N�:���<bC<rO��'��5��k8'��P����D>a�5�H~�@����*>���|ݨ�����ܓ7>�_��י;�K���>���lo=@�=�4��Q��xa�=�Ꮍ/腽�Q���=�[�{�(��,E�o������[�#�r�7��=ń\>i2>{0�!۽_��<���>�"�Vh�=]��=a;_>�	>��>�7!=`��=��7��a��B����ʨ��:��=ݡ����T�\h@<���=����.�ǽ�%8��>k=9�d�r=�0������=�� <�wq>�)�7;�=�� ɽ?F=ɯI�Ǟ�=�:>�s��`>����&�=+��<Ԭ�=^	����i��|>|ʱ<g&���jv���f��e�<��
��-�����6Q�py��D�ҽ�XW�	�>r���0}��sr�� u�[c)�T�F>v�;=�<�Z>�� �|jw�n����J�	��R���@��V$p�Ǡ��%��jӼ& �=���2K���X���I�>�Q5>�g�=>ƻ>C���U����#����=;�X=�4i>�C�<�my=��׽� ���{�,�<����}��q�#�~��{�]����>��ٽ����[=ľW�`�R=17k�$�˽�5�=F�ܻ���ݾ��(��j����ҽ�l�Y��=�5=��Լ�A��>uwC=�#�=�q����>}P�<��G=tv�=���=:�ؽ��=�l���J�g�;�����۵��4�=���7��=��[�9��=iuB=A/��2Md=���=H��=�~��R�V�+�<M���-�=�,Z=��=�#:=#�=�`�<�=�<=�d�</1�=DD<����=��h���n�<��=�as=��k�ͻm`*�3Q%=瞑���>	^=Ĭ����q+:>o�c�&4=���<�K��N�(���	>��\���=���>�r�Q�/>?��f)���̍<s#��]Μ���z>:������:J^��Qe�k->�k=�.>�������=���=���=d�8�J
*>Q=i=��X��8�>;�<8�A<��M�-���榽�;W_b�g07�[�{>�_C=��>^�<�	>���;6��<�#����@��&B�2y��
G��%�=z͘��Q@=��>]���Nw<�a��AR�:����<G>Ҍ�<�J=F��Ch�=lNf<h����9�>2�=*cc�@%��a��=ءD=�T-=��[�DZf>�K=TU�q�q�9Ż����\8;���=������=O�˼��i�`�&;����<c2>қj���<=}AD>��=w���7�9>�|-��L�<��=+��;��2>�XO>���<ⓠ�Ky >��>��=�GU=s�z<��żY�S;��=H�9�I=��?o��ӧ���~<s܌=$>��_t1����=R��<��=�
>�7l= ���,=5��=�L�.|н��K>N@D=n�V�=��8����=�>�H��=-[>A�$Jɼo��<G`˽�i��Z=��=��g=�ԃ;�A�������=q�4��$�=���=��1>�r�=�;�=��f�c�=����OS�={��=Nh�=�Я=��>�F��;�=`����=��<nj�=I@�%� ��>ν�Υ=�ٕ���U>Ag�5M�=eͽ��@���aF>_̌��tB=���"A��h�<ֻ�:	{��)�=��@��.>��J�;�ż%�,>�=�GC�X�Z<�؋<`�_=X�v)>�r�=̀��r�꼿�߻^� >8A=,�J=�5�;P�=z�R=1�1>.����UT:`Y�ҩ�=�ǽ�PR=��Y�7��=�G���<ֶ%>r�=�b۽� �/:߼`��t���8E]<�z�=�ܽ��<.���ϟ˻���@��O��>r�=��=ũ�<�@F�+�^�n-��E��q.�=S�^�o��<�{�=��E>h�/���	���X>uf'>�Q==����b����=�F�=
=��=a�=��}=%9>R@��
=��=D�����>�>�>����V(��=�=�2�;ui��h=9�q�
�=T(
��P\=�:�=O��=��>p�M�ū꼑��CN̽�Yl�������<�>�=��>D�/<$��;:�7�)��>�F��~��0���¡=$c�!_�:)J�=DO�<L�B�_��=�\<�_o�^�����\<��=^��=��s>��8>�?�n��;�����>Y�=����Y����>O�^� :<1�����¼T�>=:,>�>�����=�5����=�_���μ���~>�8�<�J%>I���/����h�V?=#lD��nV=+^�v��=�ܫ�@ִ=���jeɼ�ϼ�f���q�O^�;IK�����=$�E��kO=�3n�dl�<ז���
���
��ª�=Aס=�ą��ɐ= b���5n>i��C~�>2�1���=>0>\�=�1�<����!���!<B��=l�]�:����= G��������=��<�eKɽI#��G|�<�=WQ<=4Ə���U�+ً=�,ེ$�>ꢼ���M=3�OJ ��峽�Bɽ�_�=�*>�R����T=��=̼==ݭ̼��>�:��i��=�F2�^s�<m�@=A]�;�Ѹ���ɽW�˼�T9=3����<�_�J`>3���38]�iT<>�@,�h�t=v�R=�%��>>���y�=��=<��=�.콻!}=Ѥ�<+R����w=c%�=�����s=` -��O���%�=Q�p>'��1H���������	����>�`�<YI����=���=-u�=���	�<i�\=�|v�4ؽ�1>qC-�Ӣ��O�2>dY>(�=�~���=؃��.�M�t����;q'�v��<�CF���P;'�H�Ž�%��Miӽs��_E�<� �X��H=m��Z���r����=�hB=e9��:����[g=jW�/W]���G�UU��5��]f=���@iʽ���Iý�Ѥ�X�l"����=�#�<H��=���kߜ=����[n���͍<��+�#�U���)=rV�<����Zu���>�ZE���Ǳ�*3(����e=_���E=y ��ǩ޽(z��W3=��<.W���k�]��yP��{	�s[(=�Bٽ�e��,���"�b��J�<!��<<�ܽ��>=�u<��Q>��=��;�B�,�={n�=kV�=o�!�)V<֭h>���=�=r�'!>���;$�/>���=�3>v�<v�<�Ox��¤=P�=�P>e����bW=��������ż��=��>?�>@Ѱ=!�K<���=�mf�K�S�,�{�L�w.>p����=�B��~� �=F�-=+��;)�F��k@>�Tw>,\�=�*�=�F=����:>�I����=!#>=ڽ ;�=yL��d�� p>9%p=��<a�5>{)�="�T=aF�&Ai= l��2�<�">��=jq>@>5E�mÓ�N�(���U��Ŝ=�#�=�~I���-��/D��=>�>O�=5���0����j�=�⡽���$D�I�=�1=;����0%>k��μsV/=$W�-�{<�6�=�_G>�`���=4�Ž/9>���='�I�c}�<�>0�D��cV=N0F�(Eo�Ͳ�{=zQ�8�}�=�r�=�TƼM����=��=/��<��=` =�bt=&:�=�=�����0��Pli�ک�~�u�_=�Ԍ���R=A�[=HՊ=x���:���>�<�[˽āC�=^�)>�{=}x_=aR�=ݐ�=��.>zi=�ƽG���o�=
Y�>P�N�8��6��=Q�<�=>^�=%�߽�x�=�"�=�ߗ���̽K���?2��eH���G��B�9�)�>��м����ÿ����=�v޽�Q`=������+�즎=b�=��~����:������݂�� ~����=�->�$2=q>��h>J��� ���$>�6���<�嘽�z�=�S�=O��ȇ>�f��)R=D�[������	�=4wK���E��=Ï=�<��r�꽇���V=ߎv>p˻��T>�,�<l�>�K
>0�?����<O�J>A��=��
>tXV=����c(��#,�	e� �;�=�w��ϵ>ُ1�̊$=Z�=S=���<�$�=yS=��=���=�3�<q�4���=�ʻ�Ӽe{l=b�S<�n_�ou=�c=�M<�9�=臿=�9���c=D!�Ԝ�R'�~��=�r�=��=m]ļy��<�:.�Ѽn��=��<���=5��=H�e�g�=�k&�/��=���/_[�<O�<��/�L؞<��I=`x����\<�h7�S	�=��g=��}>�5����=0��^J<L��=�Q�=��=h�ɻ��m��qj���N>��<z�=> -=,�=!5ѽ�3�<�l>�G�=�֍<�9vY,����=&��=&�1��Ӿ=�W �m�_=~��}i�4p�=��X��.">@�>�ާ:n	ȽnI�����=,	>0Ͻ>A>�]<���=y_�=EX=�n�=5���H��@:v>qv�1,�=�,>���=Ed>M����6$��3T<u��<�z>�+�!1�>c�=羮�z04��3<�˞�,��$m=�S��'��9)<'y��;�"�r�=ur��Eڼq�>�[=X�>��/>�9=��=���L=u�,�Ӟ�=��=R=<ys���=`�<��p�}�-���<GtR=�"���>l����=����=�3����<7䜽,�%=�-0�R���`��=���<���c�!C6>5����8>�G�a�>�{=��e<P���_�� 8���uE�>�>���=�<
3�=��I��y<^����q��qq>�����)��w=&�)>��h�{t�~4�=?Z�=Ro��gN�p"1>7��5�L�����Ý���^�=4�����������h�� H��%H^>�`t>�vR��SI�H��r���3�>�t&��^=��>��[�4�ѽ�;�<G�l���,��o?�Dn=S8����;C�=���<ey[����=01��e�=����a>�N�S�=ȍ�=�=�t�=/e¼��=�tg;W���͊��r���}G�aE��b�<4���(��}D��D׉��_Q�L��=)ݻ��O[�,����Y;1w�=��A=��;�Td=k_�������>�̟����O=g��%g����<`��/н��;��н��½�۽= ����������#�=ӽ��"=��<+I�=qf���w
<I�=�����2<[=�<�e=��"�s������,��<���<KȽo�μ�����=]v3=��(�K����ݻ5q�<��ٽ�i=\-c�@�w���O�/���ɗ��x���1b۽*��Ϝg��yW�+�*��R��&�=wb߽�eý9�>��=��=��9>�+5=���=��J��k�=5᛼~�D�H���Gh���o�v��=c0=*�5=�.����<�A?=�/v=&�k<k=h��<��&>(��� ļ��!=g>9ѥ=0*=ߠm�b^3<o�i���s>ڬڽ(إ=��+�d�P>g���\8>�Y�=M�»�7�=/�8�ܯ=ˢ��=0����Z>��սD��<�P=O.K=>ֲ����=|^<�mнU,���ky=dԸ��?=П0>Eq��}/>_���(n=��O��޽�U����+SJ=|z�<!Ƽ:=|�=�e_�UZ�=�|r=</��̼,솽kv>�?B�]�H��2�;刽�o��������;�<�R�<sc)��������*�=�?��u=_+����=)炼�����<��H>��̽��?>�ؼ���=��-�n�Ž�$�<5.�j3н�� >����Q�>�������r�N<���*�	={cY��g>�]�g���Z�ټk��<�������>�&��y��>���o�Z5�=נ����=Z2�=b+�>�_ =N�N= P�;�P�=D��=���=yء=���;"��=
���Ӈ�z��=K���u>�8������?���j���Pc�K�켄�&=��;4�%��ς�ˋ�=�ϼ��+�<��,�_?R=��`= =��ȼtBԽ:b��m>��~��1�=1�>��7��4�=���=*�:>o̻���>�|����Ի��<n �=�Y{=n��=*
b=z?½PV='1-=�sy=Ar����;!�b=T#�<�F��Y=�0�=�>:6��$��Ԓ=4m�=m�> +�='3��c�X���}���=/>��s�o�<f[j=ڞ_�+�ȽE>��=�
V���9jH=�+>S阽����'�bn�enR���:��<��=p��=��[� ��=��>@�g�bQu�L�=�d=�ҼCŽUz5��>Q���9>�s	���=�?l���������=�$=�$�;�j�Kd-���=l⬽����Ԟ>	�N�Qޡ=��cwI��n��,�f��4�:>����{�B=ti�gZD; !��e=t����ּ �=�K=���X��=�?8���=>��<�e��[d��&�j�?��CM�=���k��0k��q� t��!��=1�<=��>&�7�LƼ��O>�>ǉz=�d�=�Z�����8;���`�=�~+�`�=����D�I�/(�=���=l�=�ZD��pR��'����=���<��=7�(>N'N���<]��=�D�c�Qo�;);����>/!���=��=�C
���>�C%�Z�=.J���޼��2=pʽSS=>�������<=��h=l��h��=��̽Mc��3����<�iҽ�&#>ji���reƽV�<��u�!x�;�>pc6=��񽮿�=�zC�|�]=���<�T-;�����m@>xk���eF=�\���>j��,��=�"<,&>=p<���
fg=[�=es&=�I={�=��k=��6=a�2=;c�<	
���<+�� ��;Bec���;��>�7->r� �-�=aiO>��j=�W����R�&�=ޥ�=�G5�dC�7&<���B���L>y6<=��(>g H�jY�=�6U�h���	<K{'=����U��=���U�����=�X����-:>:�zi&>�>>,1u<�*�=g͑��<<OԽF�м�E��hz`�*!ƽ�9漀�2>�`1=8��=e6�
�u=�:U�3X)���=�x��d=k�d>x��Y��=�bνR\=�;�=��=�x9>X~B>�����l���o�{����(>����dy=bY;M��>����-�:4H��v7�<��>6�O=M>�5>!'�r� =ޯ=��Խ1�=.�=���C�=G�v�V0c�N�h��0�=a9�.��<��p��y_>,�<W�=�E>�m��<�l=*6>0�:>Z�=�0�<}܂<nL���i��>�_���=��=��s��=�>�U=��5�R����ܽ~������=��<�S��%�>2
�+N�<G��=�c;й#�~x	=ċ���P�?�=O�=�h>s3)<i�=�z{��w=�j�<.�>1ٽ׸/>B�;V<Hlν8�>�nb=��>�����,xC��p�AJ���E����B��;p[<�_(>�2D=��'>.@<̏�<l�����j>c尿�&<p�Lr��Vo���o(=M�=O.�<�W�<��>`�Լ��5<��=;�s=�i���^�=� -��m��ǒ��K=qZm��s@>�<����=wU��Ih =��̽��=<ؠ�"�X>"���N���=+�X�D�ؽ;�/>/y����=1.m=o�=7��@J��l�������d!�;3�oq�6�E>ks��#��=Xs\�¡X=���=v�w=~�g>9-<�5:>�g=e����μ�v><�N?=F�=+��$�0>�����!�=]m&�s�1�=n����h>Wl:��F(>J��=��{=�il��m���>�c>Ą =�_ݾ�4-�J��=�rW>�B�=N���-�=Т�<ܤ<��y=G�=
α=K� >�e.��y�.�;�e��c�8>�M�T/�<�->�h�<�Ԡ=�����*�ec=T�F=�6��Q��������=	��=�����L>��>
�B��쁽��|��d��\q�d�q��B,>y�#>Z�6�K:>A�=�g����J������O��L�='�n��f�=;�=��>#<��@>��=١=%�=?�E=������o[���M=2	h>�H�>�m���R8>s��� )'���C��\�<ueD�
f�=�O��|=ц=Nr;��>�6=����J�=5�\=2��=7G�=v���ҹ=�ͽz�ݽ���=���='��Y�|�=.�=q#�G��g�ڼ�l̽�Q=���	��=)��=7�l���<_��<�~}�rB=�5R��e->�l=��@���P>�*;=�,�=�-�=d��=�C=�3���6>������>"��<����=�i<�W�����9 j�<��>T�㽛nҽR�5�w��� ߼i��=_��= �T�@�=�Y�<�v�=kL)��^'�L�.��s�=�B�82�=�\�=\��U2>�>�-ƽ�擽���==����^u�=��5>[ϳ=��C=O�F��:n=�ܽ�0�=|��=�!>�r>3o*��=�=�l+=�X*�A=��;����3� ��=��=�D]�E�>�<�=�'^< _н�dV���Z��ֽ X�=`o��$�G���a�^:�A�>���g���nNA���=��>�=�h���ν�ؔ�w�>����½I뽶�Ѽ��</��=D[>�[�=��>���D>�qy�)��>L�l�~	���=�m}���4=�e>���><
�=`B����<�nR�y-��k��҅=��l���'�<ո�=��7����<"lD��=�|�>څ�=��=v���c�=Z�>lgü�'z=��<��=���&X��N��MH=���=Ϧ��+�(����=����F�<3>��2���Խ���I`�=��	<��ļ�2��'l��ܽ�9�=����۬;$s�<�=0^��:u����>���U�=��E��[]�����I�� 3>�����8�����:L>%�[>�y��R�=��=���|�=��E>�2J� 5��<dj�=/���:��%�>�(��X�Z��=؎�=YA�U��=9��-���>�+�R<�~;#e>(8��P�<<'�<k>�=����������=W>���(��goP=h�_�9��6�?=�>Q�=<�<�E'>�M�^�3=�V�<�/�=4�= u[=p.%�^��=vN�=�Fd=��2��6�=�ǐ=� >������=j/�=���,=�� �bA��'�=���=I�q��i�>5�;-���5=�=K%�=#;ϻBhl:4>ν����Ν��dD�6��<S	�DҾ��=e6>�����*$�f��;g>�[�=�NG���>�1 >�Wݽ,�Oz�,��=))ƽ��(>���=P=O�
>�s)=��=硕�/.=��X)����0=?`�<#��<e=N�=>�@=5��=�J=^�p>@8�־�=R����}<�b�����<E
��X>jBڽb�#�v;˽�=P>�Y9�+~;>���;�I���+����=��+��(>��ܽ �/>��=�cüRݓ= U��,�:�w)`=.��<>[>�	�N�X>{M����E>d�>�=��I>đ���<lF�<v��"�E>��=Z+�=���D~1�@�=��:��}>��ú$3�<��>Y3�=�[��G��=u�%���i>?c����L-�="�y�j\��K"�����=n�%�1'�iWD��d=�^A;�|��g�=�j�=�=v�Ӭ�=?w=]�<f�Z=�l�>)����>�=��=Q��<e˛<�w==<�I=ɍ����=V%�� {H>E��=,��=�`�QyK;�$w������$�>�2=2sսIc>��<$�>=��==�=��%>]۽&9)=�e�>fܞ=�0>ohV��C�=6�c�%�=�U���TＺ�>'���n�����>H��=b��E��GH'=d�e�� A>�nI=�z>�@=Kŋ>�-������,>� ��`:�S^9=�@
=��Z=�U%=Y/=�L�=�lR�`O@�%�ƼT����=��=/�=�}=������i>Up>��=���<���=@X�9I}�=��D=꩒=m�=�S�S^}���<=��i>�cU���=��6�I).>�<�'�=�U|=�N��Y>	�=�c�=�5q=.4���������傼�F>�}���e=2�z�7�/��9弊�|��"h��Ȇ��w �K�i=+�ݽ��=MH���='>�u}=e���>��0����;��=��;�m�7=*S�=�d>t�=���=`CD=���z�=_�=�'&=FR+>枊=8� =�\]=Y�Ľ��t>�f�=�v4<�͵��}<�d�/|�=��=�A��I�^��Z3�"��:33p=y%>>�`�<�X������ȭ�������?�=��ּ�i��4q =y����,;Z��~9^=)����J�}��=x��=8���Ԯ4=�s�����צP>^�4��[����u�/<*ʉ=�勼$�=Ù�y��=�7=�#�=������=�=������u�y>���>���6�<��;�ˋ�~U\��ʆ���<���=���|��vU���̾�C�=d >f?�>�L���a7S=|�4��L��tO>������s�=��=� {=� y���%���;:�����@�E���B<��p<Dݻ=�ý� d�=��<�Q�=��ٽ-�%��j!=�£>a묽Β>$=��<�p���G�jQ�?�U=�h�7�>�>� �����!+>��>�>��ӽ^_(�S��(M=`%=� >�P���=���������$>]{޽Yc�=���XuV<	+�=�aļ
�<�;�<`j��e<���a�˻3c>�q=��<�
�=��1=�e�N=1=�S#>��=�p�i9W�����O0���C�=���kG={�<����+
�=_X��H�>��罓�e<�[=���>��=�7=�[���+@=U}�=4�$�݊�=�`{=%eG���h�1����U!>d+O=��=�(��
�=l7���>=1ȼ���=�x����*>]S��|$>N��<�~�=��.���=>2�.>ڀO>�p><�0�;�3���[�½F@>3����:>�!<�����"��5n�s���	Ք��`�<sC!>2ˣ;g�<�g"���¸2&%��%��H$2�gr����=��=Ti;=׼O=���׺=˙�n#	>=�F�>'�V�=�.!>��ѽ�;��1=�`�P�����=�6ɻt��=�=����|��
�S=�l�=���=���A_�=�e�=[}�=�B�A�k�&�=��=�cϽ����X�C�߼�O����<�0�@w��&<���9�ҽkK̽���ֽ[����p=���='r��,�=K۟�3Y��=��/�RHл2VL�H�`=�W�<F7�;�5Ľ��R��ʽ<���72�[b���^������Z�I���X"=0[�<�D=�Zֽ�콆�p�$���dmϽn�<d���@����B����6��;ǔd����<�= &��X6������ٽ������ռ���=~ь=O�< ��ܶ =����@��=�d=z�N|轭I�;4F3=)Mƽ�ݑ�ߡ����k=���=��=��>[���`$=���O��=.�^<�=��=AY��-h<f�0����J�	>']������\��<��-=
�¼�/�<Q��=����7>Ip�=�k��3��Y^b���ؽtYv>ϋ��c�ͻ�X;=���w��='�]<iK+��>m,����߽�-˼��[�xPV�kT�=B4 =[D=]%^>�E>�W:�s<>�����<an=H＿�����=���<���Li���`>f���4�0=k�=�N$=/6=Z���k%4=Bo;�ܖ<���=�d">k��=�PϽ��>2 �m�6�����(�=-Ɇ�o<O���L>�O�=�W�=�9й�"c=c���fY>6S�= �$=��[�Հ#;�~�z@�=�0�<F�J<�����)>�� �6 =}����~���ҽ6�>���:X�=>�"�=�
>���:�=7<��e4�<��$=���<;�= U�=�w`= #��e�������;P��e>�	� �=�.��a
�����:>�`r�����dϼcG�=��&��<�>ʆ��R�9���>�e��A=�%q�
�o;����͖=��=�M�>~^�;%P>n
'=�=�F!�#!�<���]��<s�0=*��<�*�<��=��=��S�v�n� ����<sX�=]��3�y�t�=c�����=\�<]�@����s߽��f6޽��=��`t>��G;(�#=�gs��o��~�i��7�:=.���g��=�~�xL5�8^�=�7��h�<�r�ŻP���>V�=i?��*�>g�)����!�&G_>�V�9�\��J'�J��H��`Kx=��=z�J>3_=:ۼ���$�!J�����O�=,��Rff=�j.>䠾 q>�B�|	>��B=*�>�����>;�:�`ڽ���l><\�f� >|��;��L��>	N=\��h���z�����߼.e>.�;�G�>��$�rG�<��=z=~��I�p�����U�\hB��M�="N3��8}��;��ݽ	R	��=�Y�
/�<��(�jX�=U<>���<B>|������J;��G�����=ۅ�>�o->G&2>���� �B<G<�>���<�|/�/ti�����uR?=Uم=��~�hdP>�y�����~�=�̽讕��æ�Ǻ> "�=� I�G��x1[�U�&�k�N�(36>���;� E>0��=�R=�?���ڽ��>J��>4�IԐ=H.>���˽,JY��=�6>=�D>�Z��C��(3�=n*k�@�����>�=x�>HM�_��=�H�=����<�˼��,=�
�,XI��= b���}׽}ŽZh)����=ˊ�a9�lC=t�b�R[�=�W=�&�=�N�oݼ���ƾ2�b����N�(>7��=M��=V��;�P����;����V6>�fL�c!J����>8<�=*/>w�׽���N[=����ͽ+�A>
4 >��hQ�}��ayͽ�����>(_=�1�=㇓���<��I�v�U=���=��`>f�ƽ��=��6=���zH�<<I�=��F��׬�'�辵]��ǡ&<^>>�)K>& �=�- ��;���Dd=�� ����=���u�< y,�8�C=�ޠ=\��=B�罥���5L�s�/�%Q���h�=�-��#>��݋=A�ݽv���#��� �<�K�������y�=m�?�K��=vE��8���˰=��)=�V*�L~�>m!��DܼPZ����<%{���y��8���g��3܁�!����Hl;]�=�}>�/�=��2=s\
�ѤC�6|>&�K<j�=[me>Z�>|ꌾa� =�����QȜ�*z�B�>���=bJ�;=l��m��4?��Y�=��<�>@�:�ib�����(w�<6R>�޽;?m�=+Pz>�{=�{=���=�V��ے<�u��*�a>�2=\d�=�,<�?P��콨�;=���<����D��I�"�=:�9���=h�=nN�PF��?l>/ݴ����(z�<p`����6=X�=��Y�V���>�4:�=h𢾉fN>��>���F>��~�2>B�=�%G=nm>�ȽK�-�Tn޻U!I�`=�,��4��y�a>(���W=hX�=HA>�
o>���=E�ֽ>������:)u���@���o����;�v���
>ސk�m!7�~�=��U=9�M>�[X=:_y=�5�>�?@>,��2�<�I0��{2>�N�<�D���Eػ9�	��0ʽk"V����=!'=a�%=�*��d�.<�	��%/Y��U�=�5�=Y='�<���<<<I�_��_�<���=��ҽ�O�=K�b��ѽ^���k9+=�ȟ��� 
>u٪��⥸Du���}=�B佤�=k��%ӽonN>9m�=�]ǽ0�B�.§��M���=5���%��=�l�p�E���W<L>H<-= '(=�F�>��@=�*��;K��!��<�G,��ݵ>=Ն{��|�=��=��x=�(�kdQ���=��=�VV=@����V�= n���I=�Y=�Խ%��,>��Ӽ�� >Xa%>iI�=��=Tdp>Y�><i	��*�=R5>n��]�����{�*�N�K>4�P�Nڬ�� >�~=�*n;���d[=GG�="�/>~<O=��0>��N>�ݧ��?����=�?<O����~=*I>�`�=��+�O�=bWU>�['=3�r��Ə=|2�=P��'=0{�=^�=G�h�J�/=�k�{��;����ʼX���>5��6�N�S�́G=��=����<�z�|�+��w����`���<�L�<���%�O=�^l��0�=��&=�|��P�<�Ȧ=�/��七���<$�=�.��bh>�l�=Y�z=A�=�;�=��x+F=��a�=��=M'�?�>��>���o��=���=�3x=Z��`�=�T1��Q��~���:�=x�=JּO7�<UB�=|1�0��$>��=�N����=� �=���='���f��.sP>t���j�=�W��?�>Iʢ����< N��Y�<�e3=b٪=~�˼�}�(R'�5h�=�/��>ٞ<qt��nc��Њ�=�b%>L�=���=���=�>���Eư=A<ż���C4w:m��=�l<Z��Pd#�OG{�n�&;�A����Ǽ�A�=��T�b��=��*>T�ѽeX<��W�\����3w���)=AQٽ��<�{ὍPy�zd)�Ɵ8>�+2=\�Ｑ�>�1=Yb&>t�=�҂������=��<���=.b�=Yy�<u�>��h=	_�=�Y�l떽p�۽S�I����=*=t���,.<���=��<8^�=���;b77=��^�ae+>�˽�kO��O'=%�ͽ/�t=�	��+��sΆ<r�=��2Ľ(�d>�<.84Lb=�<;� ռ�_���%�d��=�֝�(��=��,�d�������4�j�ݼ9n�;�O���y,�$W>	�?>��J>�=��yf���ά����=�p �'�d��>�)�'�=�C>)���ϗ޽�;�E��;��q��W���,�2	E>�	1=)��a]=���=G�׽��нGa=�X�=��;�0<ĝܽX�O=���=�����]p='�>K��YԽ��>��a>ѩ���>�?N�p�=WH�=�D7�z����cl���z���x��MN=p沽P4�=� ��i>R������4y���`׼I�m!ԽJ��=�B6�j�½�6���B�S�=��/�0>�_<��=�h��U&=����<s�S��}v>l��=%�=��%=�H=�r�=��>�E�=
費(���Xؽ��=�����C��!��>[��a��e��xl{��4��>kv�	�=��>��d�5S�={X����]��4Yo=���5f�`w�=B�8��a�A�*�	�j>E��x�����@+�v��=%�>�l��{/��^wd=?��<�I>C�n�X1���z:h��<��8�Kǎ=7C"���+��O�����'/�SPj��� >$j�.��)�>�?�;�y���v����=��=�n鼬�>h���
)"�S��=^y��n��<�UC����=��B��J��=F� ��)����<�_b�=���=��>�{=%1�;��=�.��J8�=�0���">俕=	�ɱh=�<�=���=21μ�t��$>[���5мP22�@���~*����=��H�1�X>�3>V��#<)�D�9>i=�q�=;���/�
>je>1�@���=�>&n��3�<'˽����-����dl��<=�>�ǽm!^�lo=*�R�?}ͼ�:>��r<�O.>:��z[z����=2-�=wl�=�u@�2K�;��>cӾJ�׾�n�=�p=�m�<~4���
�׼�?�=���=³㽄X�=�=���=�K;�D">cr=���(�<�2�=��j=c�=�AŽZ�<~��<o"��z׽v����}�=��>�V;�R`C���=u��;w���'��ʽY㣽}}�����ZWD>���>5�$��/���瀽�z�=ec>S�<De�L;��p�����\�=\+>��1����;�Z��x�=2rԽ��>*}ɽ<��=*��3�j>q�5>8>>���tb�FBD�!�ݽ�ֻ�4>,�T�^29�6��>HR>�,�=�q\>�W�<K��Jeb=��5>g �W�r��/=P�<w0D<���<�U<�?=��%��
��y��C(y=cVb���>��= >�?$>�.��J�����񬿼Tjr�足=H��=!^=�s��
F	���=����9?��:=<PD=���μ��=�`��t~�;�b�=��J�KO=\ʻH��@�#6@�V��=)�<�{�J�M>��t<�3��`��<�"���B�W��=�'>�ق��c>Y ��&����=T�����<��-���M> �d�@;>�n6�@�=�߲=a��U=�C>Q^�f!��KMq=
��=�)�=�Ȼt�$>*��<6���� >'��)� >�}�<'ӆ;��<�^W=��y�2��<�K��z]�=�Rt�c<d��<��K����=E���7�=�-�=@       ��ϻ��;�Wb<�혼�Q>��=n�=(>���=+n:=Vi�=�tF=�����\�=���<6��=hl<�5	�m�=
TŽq?�=���=�B>�|=m&=���=��<=��>|�=J^>��=CR��:=�'�C�=.�>o�;8�u;�N=pJ�=S=�=x�=��4��$Q��Si=�L<���υ ;I������<$�>��%�8-ļ�wa=��=F2��L'>��x=�|r���=���<�?�<       �-��d{x>�|>�s>���=PG�=��e��TC��'�}���>ľ�=O�>F+:��奾јz���c�v�>K�<=)]>